package com.gestureface

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log

class AppMonitorService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private var isRunning = false

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        val notification : Notification
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notification = Notification.Builder(this, "GestureFaceLocker")
                .setContentTitle("GestureFace")
                .setContentText("Sécurité active...")
                .setSmallIcon(android.R.drawable.ic_secure)
                .build()
        } else {
            notification = Notification.Builder(this)
                .setContentTitle("GestureFace")
                .setContentText("Sécurité active...")
                .setSmallIcon(android.R.drawable.ic_secure)
                .build()
        }
        startForeground(1, notification)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (!isRunning) {
            isRunning = true
            startMonitoring()
        }
        return START_STICKY
    }

    private fun startMonitoring() {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        
        handler.post(object : Runnable {
            override fun run() {
                val time = System.currentTimeMillis()
                val stats = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, time - 1000 * 10, time)

                if (stats != null && stats.isNotEmpty()) {
                    val sortedStats = stats.sortedByDescending { it.lastTimeUsed }
                    val foregroundApp = sortedStats.first().packageName

                    // READ PROTECTED APPS from SharedPreferences
                    val prefs = getSharedPreferences("com.gestureface.locker_prefs", Context.MODE_PRIVATE)
                    val protectedAppsSet = prefs.getStringSet("protected_apps", setOf()) ?: setOf()
                    val protectedApps = protectedAppsSet.toList()
                    
                    if (protectedApps.contains(foregroundApp) && foregroundApp != "com.gestureface") {
                        Log.d("AppMonitor", "App protégée lancée : $foregroundApp")
                        showLockOverlay(foregroundApp)
                    } else if (foregroundApp != "com.gestureface") {
                        // Reset overlay state if an unprotected app is used (and not GestureFace itself)
                        isOverlayShowing = false
                    }
                }
                
                if (isRunning) {
                    handler.postDelayed(this, 500) // Verification toutes les 500ms
                }
            }
        })
    }
    
    private var isOverlayShowing = false

    private fun showLockOverlay(packageName: String) {
        if(isOverlayShowing) return
        
        // Lance l'écran Flutter (MainActivity) par dessus l'application cible
        val lockIntent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("locked_app", packageName)
        }
        startActivity(lockIntent)
        isOverlayShowing = true
    }

    override fun onDestroy() {
        isRunning = false
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "GestureFaceLocker",
                "GestureFace Service en arrière-plan",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}
