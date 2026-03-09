package com.gestureface

import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.gestureface/applocker"

    override fun getInitialRoute(): String {
        val lockedApp = intent.getStringExtra("locked_app")
        if (lockedApp != null) {
            return "/lock_overlay"
        }
        return super.getInitialRoute()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Pass the app package name if we are launching into lock_overlay
        val lockedApp = intent.getStringExtra("locked_app")
        if (lockedApp != null) {
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("setOverlayApp", lockedApp)
        }
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startMonitorService" -> {
                    startMonitorService()
                    result.success("Service Started")
                }
                "updateProtectedApps" -> {
                    val apps = call.argument<List<String>>("apps") ?: listOf()
                    val prefs = getSharedPreferences("com.gestureface.locker_prefs", android.content.Context.MODE_PRIVATE)
                    prefs.edit().putStringSet("protected_apps", apps.toSet()).apply()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startMonitorService() {
        val serviceIntent = Intent(this, AppMonitorService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }
}
