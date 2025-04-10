package com.example.travail_fute

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.provider.Telephony
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Date
import java.util.Locale
import java.text.SimpleDateFormat

class MainActivity : FlutterActivity() {
    private val SMS_CHANNEL = "sms_channel"
    private val REQUEST_CODE_SMS_PERMISSION = 1
    private var resultCallback: MethodChannel.Result? = null

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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSms" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED) {
                        val smsList = getSms()
                        result.success(smsList)
                    } else {
                        resultCallback = result
                        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_SMS), REQUEST_CODE_SMS_PERMISSION)
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
                val (phoneNumber, messageBody) = parseSharedText(sharedText)
                val finalPhoneNumber = phoneNumber ?: if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED) {
                    findPhoneNumberByBody(messageBody)
                } else null

                val smsData = mapOf(
                    "phoneNumber" to (finalPhoneNumber ?: "Unknown"),
                    "body" to messageBody
                )
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, SMS_CHANNEL)
                    .invokeMethod("onSmsShared", smsData)
            }
        }
    }

    private fun parseSharedText(sharedText: String): Pair<String?, String> {
        // Improved patterns to match various SMS sharing formats
        val patterns = listOf(
            Regex("From: ([+]?[0-9\\-\\s]+)(?:\n\n|\n)(.*)", RegexOption.DOT_MATCHES_ALL),  // "From: +123...\n\nMessage"
            Regex("Sender: ([+]?[0-9\\-\\s]+)(?:\n\n|\n)(.*)", RegexOption.DOT_MATCHES_ALL), // "Sender: +123...\n\nMessage"
            Regex("([+]?[0-9\\-\\s]+): (.*)", RegexOption.DOT_MATCHES_ALL),                  // "+123...: Message"
            Regex("\\(([+]?[0-9\\-\\s]+)\\)(.*)", RegexOption.DOT_MATCHES_ALL)               // "(+123...) Message"
        )

        for (pattern in patterns) {
            val match = pattern.find(sharedText)
            if (match != null) {
                val phoneNumber = match.groups[1]?.value?.trim()?.replace("[^+0-9]".toRegex(), "")
                val messageBody = match.groups[2]?.value?.trim() ?: sharedText
                if (phoneNumber != null && phoneNumber.length >= 5) { // Basic validation
                    return Pair(phoneNumber, messageBody)
                }
            }
        }

        // If no pattern matched, try to extract any phone number from the text
        val phonePattern = Regex("([+]?[0-9\\-\\s]{5,})") // At least 5 digits
        val phoneMatch = phonePattern.find(sharedText)
        val extractedNumber = phoneMatch?.value?.replace("[^+0-9]".toRegex(), "")
        
        return Pair(
            if (extractedNumber != null && extractedNumber.length >= 5) extractedNumber else null,
            sharedText.trim()
        )
    }

    private fun findPhoneNumberByBody(body: String): String? {
        if (body.isBlank()) return null
        
        val allSms = getSms()
        val trimmedBody = body.trim()
        val bodyWords = trimmedBody.split("\\s+".toRegex()).take(5) // First few words
        
        // Try to find exact match first
        allSms.firstOrNull { (it["body"] as String).trim() == trimmedBody }?.let {
            return it["address"] as? String
        }
        
        // Try partial match (first few words)
        if (bodyWords.size > 2) {
            val partialMatch = allSms.firstOrNull { sms ->
                val smsBody = (sms["body"] as String).trim()
                bodyWords.all { word -> smsBody.contains(word) }
            }
            partialMatch?.let { return it["address"] as? String }
        }
        
        // Try to find any SMS containing parts of the shared text
        val significantPart = if (trimmedBody.length > 20) {
            trimmedBody.substring(0, 20) + "..." // First 20 chars
        } else {
            trimmedBody
        }
        
        allSms.firstOrNull { (it["body"] as String).contains(significantPart) }?.let {
            return it["address"] as? String
        }
        
        return null
    }

    private fun getSms(): List<Map<String, Any>> {
        val smsList = mutableListOf<Map<String, Any>>()
        val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())

        val inboxCursor = contentResolver.query(
            Telephony.Sms.Inbox.CONTENT_URI, 
            arrayOf(
                Telephony.Sms.BODY,
                Telephony.Sms.ADDRESS,
                Telephony.Sms.DATE
            ), 
            null, null, 
            "${Telephony.Sms.DATE} DESC LIMIT 100" // Get recent 100 messages for better performance
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
                    "body" to it.getString(indexBody) ?: "",
                    "type" to "received",
                    "date" to dateMillis
                )
                smsList.add(sms)
            }
        }

        // No need for sent/drafts in this case as we're just looking for received messages
        // Sort by date in descending order (newest first)
        smsList.sortByDescending { it["date"] as Long }

        return smsList.map { sms ->
            sms + ("formattedDate" to dateFormat.format(Date(sms["date"] as Long)))
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            REQUEST_CODE_SMS_PERMISSION -> {
                if ((grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
                    resultCallback?.success(getSms())
                } else {
                    resultCallback?.error("PERMISSION_DENIED", "SMS permission denied", null)
                }
                resultCallback = null
            }
        }
    }
}