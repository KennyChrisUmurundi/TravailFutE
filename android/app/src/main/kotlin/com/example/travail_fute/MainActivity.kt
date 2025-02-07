package com.example.travail_fute

import android.Manifest
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
import android.telephony.TelephonyManager

class MainActivity : FlutterActivity() {
    private val SMS_CHANNEL = "sms_channel"
    private val PHONE_CHANNEL = "phone_channel"
    private val REQUEST_CODE_SMS_PERMISSION = 1
    private val REQUEST_CODE_PHONE_PERMISSION = 2
    private var resultCallback: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSms" -> {
                    if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.READ_SMS) == android.content.pm.PackageManager.PERMISSION_GRANTED) {
                        val smsList = getSms()
                        result.success(smsList)
                    } else {
                        resultCallback = result
                        ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.READ_SMS), REQUEST_CODE_SMS_PERMISSION)
                    }
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PHONE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPhoneNumber" -> {
                    if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.READ_PHONE_STATE) == android.content.pm.PackageManager.PERMISSION_GRANTED) {
                        val phoneNumber = getPhoneNumber()
                        result.success(phoneNumber)
                    } else {
                        resultCallback = result
                        ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.READ_PHONE_STATE), REQUEST_CODE_PHONE_PERMISSION)
                    }
                }
            }
        }
    }

    private fun getPhoneNumber(): String? {
        val telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
        return telephonyManager.line1Number
    }

    private fun getSms(): List<Map<String, Any>> {
        val smsList = mutableListOf<Map<String, Any>>()
        val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())

        val inboxCursor = contentResolver.query(Telephony.Sms.Inbox.CONTENT_URI, null, null, null, Telephony.Sms.DEFAULT_SORT_ORDER)
        inboxCursor?.use {
            val indexBody = it.getColumnIndex(Telephony.Sms.BODY)
            val indexAddress = it.getColumnIndex(Telephony.Sms.ADDRESS)
            val indexDate = it.getColumnIndex(Telephony.Sms.DATE)

            while (it.moveToNext()) {
                val dateMillis = it.getLong(indexDate) // Get timestamp in milliseconds
                val sms = mapOf(
                    "address" to it.getString(indexAddress),
                    "body" to it.getString(indexBody),
                    "type" to "received",
                    "date" to dateMillis // Store as long for sorting
                )
                smsList.add(sms)
            }
        }

        val sentCursor = contentResolver.query(Telephony.Sms.Sent.CONTENT_URI, null, null, null, Telephony.Sms.DEFAULT_SORT_ORDER)
        sentCursor?.use {
            val indexBody = it.getColumnIndex(Telephony.Sms.BODY)
            val indexAddress = it.getColumnIndex(Telephony.Sms.ADDRESS)
            val indexDate = it.getColumnIndex(Telephony.Sms.DATE)

            while (it.moveToNext()) {
                val dateMillis = it.getLong(indexDate) // Get timestamp in milliseconds
                val sms = mapOf(
                    "address" to it.getString(indexAddress),
                    "body" to it.getString(indexBody),
                    "type" to "sent",
                    "date" to dateMillis // Store as long for sorting
                )
                smsList.add(sms)
            }
        }

        // ✅ **Sort by date in ascending order**
        smsList.sortBy { it["date"] as Long }

        return smsList.map { sms ->
            sms + ("formattedDate" to dateFormat.format(Date(sms["date"] as Long))) // Convert back for display
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            REQUEST_CODE_SMS_PERMISSION -> {
                if ((grantResults.isNotEmpty() && grantResults[0] == android.content.pm.PackageManager.PERMISSION_GRANTED)) {
                    resultCallback?.success(getSms())
                } else {
                    resultCallback?.error("PERMISSION_DENIED", "SMS permission denied", null)
                }
            }
            REQUEST_CODE_PHONE_PERMISSION -> {
                if ((grantResults.isNotEmpty() && grantResults[0] == android.content.pm.PackageManager.PERMISSION_GRANTED)) {
                    resultCallback?.success(getPhoneNumber())
                } else {
                    resultCallback?.error("PERMISSION_DENIED", "Phone state permission denied", null)
                }
            }
        }
    }
}
