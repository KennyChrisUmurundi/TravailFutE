package com.example.yourapp

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.AppTheme) // Set your app's theme here
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        // ...existing code...
    }
}
