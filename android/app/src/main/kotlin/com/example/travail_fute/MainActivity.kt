package com.example.travail_fute

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.provider.Settings
import android.provider.Telephony
import android.net.Uri
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import com.google.i18n.phonenumbers.PhoneNumberUtil

class MainActivity : FlutterActivity() {
    private val SMS_CHANNEL = "sms_channel"
    private val REQUEST_CODE_SMS_PERMISSION = 1
    private var resultCallback: MethodChannel.Result? = null
    private lateinit var smsMethodChannel: MethodChannel
    private var pendingSharedData: Map<String, String>? = null // Queue for shared data
    private val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()) // Thread-safe instance

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleSharedIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleSharedIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize channel
        smsMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL)

        // Process any pending shared data
        if (pendingSharedData != null) {
            smsMethodChannel.invokeMethod("onSmsShared", pendingSharedData)
            pendingSharedData = null
        }

        smsMethodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getSms" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED) {
                        try {
                            val smsList = getSms()
                            result.success(smsList)
                        } catch (e: Exception) {
                            Log.e("MainActivity", "Error fetching SMS", e)
                            result.error("SMS_FETCH_FAILED", "Failed to fetch SMS", e.message)
                        }
                    } else {
                        resultCallback = result
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(Manifest.permission.READ_SMS),
                            REQUEST_CODE_SMS_PERMISSION
                        )
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun handleSharedIntent(intent: Intent?) {
        if (intent?.action == Intent.ACTION_SEND && intent.type == "text/plain") {
            val sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
            if (sharedText != null) {
                val parsedResult = parseSharedText(sharedText)
                val phoneNumber = parsedResult.first
                val messageBody = parsedResult.second
                val finalPhoneNumber = phoneNumber ?: if (ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.READ_SMS
                    ) == PackageManager.PERMISSION_GRANTED
                ) {
                    findPhoneNumberByBody(messageBody)
                } else null

                val smsData = mapOf(
                    "phoneNumber" to (finalPhoneNumber ?: "Unknown"),
                    "body" to messageBody
                )

                // Queue data if channel not initialized, otherwise invoke immediately
                if (!::smsMethodChannel.isInitialized) {
                    pendingSharedData = smsData
                } else {
                    smsMethodChannel.invokeMethod("onSmsShared", smsData)
                }
            }
        }
    }

    private fun parseSharedText(sharedText: String): Pair<String?, String> {
        // Use libphonenumber for robust phone number validation
        val phoneUtil = PhoneNumberUtil.getInstance()

        // Define patterns for extracting phone number and message body
        val patterns = listOf(
            Regex("From: ([+]?[0-9\\-\\s]+)(?:\n\n|\n)(.*)", RegexOption.DOT_MATCHES_ALL),
            Regex("Sender: ([+]?[0-9\\-\\s]+)(?:\n\n|\n)(.*)", RegexOption.DOT_MATCHES_ALL),
            Regex("([+]?[0-9\\-\\s]+): (.*)", RegexOption.DOT_MATCHES_ALL),
            Regex("\\(([+]?[0-9\\-\\s]+)\\)(.*)", RegexOption.DOT_MATCHES_ALL)
        )

        for (pattern in patterns) {
            val match = pattern.find(sharedText)
            if (match != null) {
                val phoneNumber = match.groups[1]?.value?.trim()?.replace("[^+0-9]".toRegex(), "")
                val messageBody = match.groups[2]?.value?.trim() ?: sharedText
                if (!phoneNumber.isNullOrEmpty()) {
                    try {
                        val parsedNumber = phoneUtil.parse(phoneNumber, "ZZ")
                        if (phoneUtil.isValidNumber(parsedNumber)) {
                            return Pair(phoneNumber, messageBody)
                        }
                    } catch (e: Exception) {
                        Log.e("MainActivity", "Invalid phone number format: $phoneNumber", e)
                    }
                }
            }
        }

        // Fallback to generic phone number regex
        val phonePattern = Regex("([+]?[0-9\\-\\s]{5,})")
        val phoneMatch = phonePattern.find(sharedText)
        val extractedNumber = phoneMatch?.value?.replace("[^+0-9]".toRegex(), "")

        return if (!extractedNumber.isNullOrEmpty()) {
            try {
                val parsedNumber = phoneUtil.parse(extractedNumber, "ZZ")
                if (phoneUtil.isValidNumber(parsedNumber)) {
                    Pair(extractedNumber, sharedText.trim())
                } else {
                    Pair(null, sharedText.trim())
                }
            } catch (e: Exception) {
                Log.e("MainActivity", "Invalid phone number format: $extractedNumber", e)
                Pair(null, sharedText.trim())
            }
        } else {
            Pair(null, sharedText.trim())
        }
    }

    private fun findPhoneNumberByBody(body: String): String? {
        if (body.isBlank()) return null
        val trimmedBody = body.trim()

        try {
            val allSms = getSms()

            // Exact match
            allSms.firstOrNull { it["body"] as String == trimmedBody }?.let {
                return it["address"] as? String
            }

            // Partial match with word-based search
            val bodyWords = trimmedBody.split("\\s+".toRegex()).take(5)
            if (bodyWords.size > 2) {
                allSms.firstOrNull { sms ->
                    val smsBody = sms["body"] as String
                    bodyWords.all { smsBody.contains(it, ignoreCase = true) }
                }?.let { return it["address"] as? String }
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Error searching SMS by body", e)
        }

        return null
    }

    private fun getSms(): List<Map<String, Any>> {
        val smsList = mutableListOf<Map<String, Any>>()

        try {
            val inboxCursor = contentResolver.query(
                Telephony.Sms.Inbox.CONTENT_URI,
                arrayOf(
                    Telephony.Sms.BODY,
                    Telephony.Sms.ADDRESS,
                    Telephony.Sms.DATE
                ),
                null,
                null,
                "${Telephony.Sms.DATE} DESC LIMIT 100"
            )

            inboxCursor?.use {
                val indexBody = it.getColumnIndex(Telephony.Sms.BODY)
                val indexAddress = it.getColumnIndex(Telephony.Sms.ADDRESS)
                val indexDate = it.getColumnIndex(Telephony.Sms.DATE)

                while (it.moveToNext()) {
                    val dateMillis = it.getLong(indexDate)
                    val address = it.getString(indexAddress) ?: "Unknown"
                    val sms = mapOf(
                        "address" to address,
                        "body" to (it.getString(indexBody) ?: ""),
                        "type" to "received",
                        "date" to dateMillis
                    )
                    smsList.add(sms)
                }
            }

            smsList.sortByDescending { it["date"] as Long }

            // Thread-safe date formatting
            return smsList.map { sms ->
                synchronized(dateFormat) {
                    sms + ("formattedDate" to dateFormat.format(Date(sms["date"] as Long)))
                }
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Error reading SMS", e)
            return emptyList()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            REQUEST_CODE_SMS_PERMISSION -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    try {
                        resultCallback?.success(getSms())
                    } catch (e: Exception) {
                        Log.e("MainActivity", "Error fetching SMS after permission granted", e)
                        resultCallback?.error("SMS_FETCH_FAILED", "Failed to fetch SMS", e.message)
                    }
                } else {
                    resultCallback?.error(
                        "PERMISSION_DENIED",
                        "SMS permission is required to read messages",
                        null
                    )
                    // Prompt user to enable permission in settings if permanently denied
                    if (!ActivityCompat.shouldShowRequestPermissionRationale(
                            this,
                            Manifest.permission.READ_SMS
                        )
                    ) {
                        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                        intent.data = Uri.fromParts("package", packageName, null)
                        startActivity(intent)
                    }
                }
                resultCallback = null
            }
        }
    }
}