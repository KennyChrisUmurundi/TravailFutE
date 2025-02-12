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

class MainActivity : FlutterActivity() {
    private val SMS_CHANNEL = "sms_channel"
    private val REQUEST_CODE_SMS_PERMISSION = 1
    private var resultCallback: MethodChannel.Result? = null

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
            }
        }
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

        // Sort by date in ascending order
        smsList.sortBy { it["date"] as Long }

        return smsList.map { sms ->
            sms + ("formattedDate" to dateFormat.format(Date(sms["date"] as Long))) // Convert back for display
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
            }
        }
    }
}
