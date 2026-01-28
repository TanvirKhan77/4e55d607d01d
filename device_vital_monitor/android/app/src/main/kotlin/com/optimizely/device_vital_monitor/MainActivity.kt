package com.optimizely.device_vital_monitor

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.os.Build
import android.os.PowerManager
import android.os.BatteryManager
import android.app.ActivityManager
import android.content.Intent
import android.content.IntentFilter
import android.provider.Settings
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.Constraints
import androidx.work.NetworkType
import java.util.UUID
import java.util.concurrent.TimeUnit
import java.lang.reflect.Method // Required for reflection approach

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.devicevitalmonitor/device"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "getThermalStatus" -> result.success(getThermalStatus())
                    "getBatteryLevel" -> result.success(getBatteryLevel())
                    "getMemoryUsage" -> result.success(getMemoryUsage())
                    "getDeviceId" -> result.success(getUniqueDeviceId())
                    "scheduleAutoLogVitals" -> {
                        val intervalMinutes = call.argument<Int>("intervalMinutes") ?: 15
                        scheduleAutoLogVitals(intervalMinutes)
                        result.success(null)
                    }
                    "cancelAutoLogVitals" -> {
                        cancelAutoLogVitals()
                        result.success(null)
                    }
                    "isAutoLoggingScheduled" -> result.success(isAutoLoggingScheduled())
                    "getLastBackgroundLogTime" -> result.success(getLastBackgroundLogTime())
                    "getScheduledInterval" -> result.success(getScheduledInterval())
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("ERROR", e.message, null)
            }
        }
    }

    private fun getThermalStatus(): Int {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Android 10+ (API 29+) - Use getCurrentThermalStatus()
                val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                when (powerManager.currentThermalStatus) {
                    PowerManager.THERMAL_STATUS_NONE -> 0
                    PowerManager.THERMAL_STATUS_LIGHT -> 1
                    PowerManager.THERMAL_STATUS_MODERATE -> 2
                    PowerManager.THERMAL_STATUS_SEVERE -> 3
                    PowerManager.THERMAL_STATUS_CRITICAL -> 4
                    PowerManager.THERMAL_STATUS_EMERGENCY -> 5
                    PowerManager.THERMAL_STATUS_SHUTDOWN -> 6
                    else -> 0
                }
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                // Android 9 (API 28) - Use getThermalHeadroom() via reflection
                getThermalHeadroomForPie()
            } else {
                0 // No thermal API support before API 28
            }
        } catch (e: Exception) {
            0 // Fallback on any error
        }
    }

    @SuppressWarnings("deprecation")
    private fun getThermalHeadroomForPie(): Int {
        // For API 28 (Android 9) only
        return try {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager

            // Using reflection to access getThermalHeadroom() which is hidden in API 28
            val method: Method = powerManager.javaClass.getMethod("getThermalHeadroom", Int::class.java)
            val headroom = method.invoke(powerManager, 0) as Float

            // Convert headroom to status (0-3 scale)
            // Thermal headroom is the temperature margin in degrees Celsius before throttling
            // Values are typically between 0.0 and maybe 10.0+
            when {
                headroom >= 10.0 -> 0  // Very cool
                headroom >= 5.0 -> 1   // Light load
                headroom >= 2.0 -> 2   // Moderate heating
                else -> 3              // Severe heating
            }
        } catch (e: Exception) {
            0 // Fallback if reflection fails
        }
    }

    private fun getBatteryLevel(): Double {
        return try {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY).toDouble()
        } catch (e: Exception) {
            try {
                val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                if (intent != null) {
                    val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
                    val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
                    if (level >= 0 && scale > 0) level * 100.0 / scale else 0.0
                } else {
                    100.0
                }
            } catch (e2: Exception) {
                0.0
            }
        }
    }

    private fun getMemoryUsage(): Double {
        return try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val memoryInfo = ActivityManager.MemoryInfo()
            activityManager.getMemoryInfo(memoryInfo)
            val used = memoryInfo.totalMem - memoryInfo.availMem
            (used.toDouble() / memoryInfo.totalMem.toDouble()) * 100.0
        } catch (e: Exception) {
            0.0
        }
    }

    private fun getUniqueDeviceId(): String {
        return try {
            val androidId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
            if (!androidId.isNullOrEmpty() && androidId != "9774d56d682e549c") {
                androidId
            } else {
                UUID.randomUUID().toString()
            }
        } catch (e: Exception) {
            UUID.randomUUID().toString()
        }
    }

    private fun scheduleAutoLogVitals(intervalMinutes: Int) {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()

        val workRequest = PeriodicWorkRequestBuilder<VitalLogWorker>(
            intervalMinutes.toLong(), TimeUnit.MINUTES
        )
            .setConstraints(constraints)
            .build()

        WorkManager.getInstance(applicationContext).enqueueUniquePeriodicWork(
            "vital_log_work",
            ExistingPeriodicWorkPolicy.UPDATE,
            workRequest
        )

        // Store preferences
        val prefs = getSharedPreferences("device_vitals_prefs", Context.MODE_PRIVATE)
        prefs.edit()
            .putBoolean("auto_logging_scheduled", true)
            .putInt("scheduled_interval", intervalMinutes)
            .apply()
    }

    private fun cancelAutoLogVitals() {
        WorkManager.getInstance(applicationContext).cancelUniqueWork("vital_log_work")

        // Update preferences
        val prefs = getSharedPreferences("device_vitals_prefs", Context.MODE_PRIVATE)
        prefs.edit()
            .putBoolean("auto_logging_scheduled", false)
            .apply()
    }

    private fun isAutoLoggingScheduled(): Boolean {
        val prefs = getSharedPreferences("device_vitals_prefs", Context.MODE_PRIVATE)
        return prefs.getBoolean("auto_logging_scheduled", false)
    }

    private fun getLastBackgroundLogTime(): Long? {
        val prefs = getSharedPreferences("device_vitals_prefs", Context.MODE_PRIVATE)
        val time = prefs.getLong("last_background_log", 0)
        return if (time > 0) time else null
    }

    private fun getScheduledInterval(): Int {
        val prefs = getSharedPreferences("device_vitals_prefs", Context.MODE_PRIVATE)
        return prefs.getInt("scheduled_interval", 15)
    }
}