package com.digiboridev.xicmpmt

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import java.util.*

class ForegroundService : Service() {
    private val notificationChannelId = "FOREGROUND_SERVICE_CHANNEL"

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
        println("FOREGROUND SERVICE CREATED")
    }

    override fun onDestroy() {
        super.onDestroy()
        println("FOREGROUND SERVICE DESTROYED")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        println("FOREGROUND SERVICE STARTED")
        try {
            // Create the notification channel
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                this.createNotificationChannel()
            }

            // Create intent for return to MainActivity
            val pendingIntent = this.createPendingIntent()

            // Create the notification
            val notification = NotificationCompat.Builder(this, notificationChannelId)
                .setOngoing(true)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("xICMP monitoring tool")
                .setContentText("Sampling service is running")
                .setContentIntent(pendingIntent)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .build()

            // To foreground
            startForeground(999, notification)
        } catch (e: Exception) {
            println("FOREGROUND SERVICE START EXCEPTION: $e")
        }
        return START_STICKY
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            notificationChannelId,
            "Foreground service",
            NotificationManager.IMPORTANCE_DEFAULT,
        )
        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(channel)
    }

    private fun createPendingIntent(): PendingIntent {
        val mainIntent = Intent(this, MainActivity::class.java)
        return PendingIntent.getActivity(this, 0, mainIntent, PendingIntent.FLAG_MUTABLE)
    }
}