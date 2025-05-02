package com.barhom_dev.menu_manager

import io.flutter.embedding.android.FlutterActivity
import com.facebook.FacebookSdk
import android.os.Bundle

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        FacebookSdk.sdkInitialize(applicationContext)
    }
} 