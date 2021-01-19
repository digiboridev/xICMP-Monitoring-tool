package com.example.pingstats

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.PowerManager
import android.os.SystemClock
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "wakeChanell"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val wakeLock: PowerManager.WakeLock =
                (getSystemService(POWER_SERVICE) as PowerManager).run {
                    newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "pingstats::Wakelock")
                }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->
            if (call.method == "wakeUp") {
                result.success("wakeUp");
            } else if (call.method == "startWakeLock"){
                result.success("wakelock started");
                wakeLock.acquire();
            } else if (call.method == "stopWakeLock"){
                result.success("wakelock stopped");
                wakeLock.release();
            }
        }
    }
}
