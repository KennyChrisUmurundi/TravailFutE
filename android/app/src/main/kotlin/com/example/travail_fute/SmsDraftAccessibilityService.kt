import android.accessibilityservice.AccessibilityService
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.os.Build
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class SmsDraftAccessibilityService : AccessibilityService() {
    private val CHANNEL = "sms_draft_channel"
    private val TAG = "SmsDraftAccessibility"

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onServiceConnected() {
        Log.d(TAG, "Accessibility service connected")
        startForegroundService()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "sms_draft_channel",
                "SMS Draft Monitor",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Monitors for unsent SMS drafts"
            }
            
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun startForegroundService() {
        val notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, "sms_draft_channel")
        } else {
            Notification.Builder(this)
        }.apply {
            setContentTitle("SMS Draft Monitor")
            setContentText("Monitoring for unsent messages")
            setSmallIcon(R.drawable.ic_notification)
            setOngoing(true)
            setPriority(Notification.PRIORITY_LOW)
        }.build()

        startForeground(1, notification)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let {
            Log.d(TAG, "Event from package: ${it.packageName}")
            
            // Add more package names as needed
            val targetPackages = listOf(
                "com.google.android.apps.messaging",    // Google Messages
                "com.samsung.android.messaging",         // Samsung Messages
                "com.android.mms"                        // AOSP Messages
            )

            if (it.packageName in targetPackages) {
                Log.d(TAG, "SMS app detected, checking for drafts...")
                val rootNode = rootInActiveWindow
                rootNode?.let { node ->
                    findAndProcessInputFields(node)
                }
            }
        }
    }

    private fun findAndProcessInputFields(node: AccessibilityNodeInfo) {
        // Try known input field IDs for different SMS apps
        val inputFieldIds = listOf(
            "com.google.android.apps.messaging:id/composer_input",  // Google Messages
            "com.samsung.android.messaging:id/message_edit_text",   // Samsung Messages
            "com.android.mms:id/embedded_text_editor"              // AOSP Messages
        )

        for (fieldId in inputFieldIds) {
            try {
                val editTexts = node.findAccessibilityNodeInfosByViewId(fieldId)
                if (editTexts.isNotEmpty()) {
                    val unsentText = editTexts[0].text?.toString()
                    if (!unsentText.isNullOrEmpty()) {
                        Log.d(TAG, "Found unsent text: $unsentText")
                        sendToFlutter(unsentText)
                        return
                    }
                }
            } catch (e: Exception) {
                Log.w(TAG, "Error checking field $fieldId: ${e.message}")
            }
        }
    }

    private fun sendToFlutter(text: String) {
        try {
            (application as? MainActivity)?.getFlutterEngine()?.let { engine ->
                MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod(
                    "onUnsentTextDetected",
                    text
                )
            } ?: run {
                // Fallback: Broadcast intent if Flutter isn't running
                Intent().apply {
                    action = "SMS_DRAFT_DETECTED"
                    putExtra("draft_text", text)
                }.also { intent ->
                    sendBroadcast(intent)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error sending to Flutter: ${e.message}")
        }
    }

    override fun onInterrupt() {
        Log.w(TAG, "Accessibility service interrupted")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Accessibility service destroyed")
    }
}