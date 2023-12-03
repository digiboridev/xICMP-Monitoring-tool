package com.digiboridev.xicmpmt

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {
    private val _ch = "main"
    private val _pm: PowerManager by lazy { getSystemService(POWER_SERVICE) as PowerManager }
    private val _wl: PowerManager.WakeLock by lazy {
        _pm.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK, "sys_wakelock::Wakelock"
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        println("CREATE")
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val method = call.method
        println("Method call: $method")

        try {
            if (method == "minimize") {
                this.moveTaskToBack(true)
                result.success("minimized")
            }
            if (method == "startWakeLock") {
                _wl.acquire(7 * 24 * 60 * 60 * 1000L /*7 days*/)
                result.success("started")
            }
            if (method == "stopWakeLock") {
                if (_wl.isHeld) _wl.release()
                result.success("stopped")
            }
            if (method == "startForegroundService") {
                val intent = Intent(this, ForegroundService::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    this.startForegroundService(intent)
                } else {
                    this.startService(intent)
                }
                result.success("started")
            }
            if (method == "stopForegroundService") {
                val intent = Intent(this, ForegroundService::class.java)
                stopService(intent)
                result.success("stopped")
            }
        } catch (e: Exception) {
            println("Method call exception: $e")
        }

    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, _ch).setMethodCallHandler(this)
    }
}