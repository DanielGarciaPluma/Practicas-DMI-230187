package com.example.toktik

import android.content.ComponentName
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val appIconChannel = "com.example.toktik/app_icon"
    private val iconAliases = mapOf(
        "normal" to "MainActivityNormal",
        "halloween" to "MainActivityHalloween",
        "christmas" to "MainActivityChristmas",
        "valentines" to "MainActivityValentines",
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appIconChannel)
            .setMethodCallHandler { call, result ->
                if (call.method != "setSeasonIcon") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val season = call.argument<String>("season")
                val alias = iconAliases[season]
                if (alias == null) {
                    result.error("invalid_season", "Unknown app icon season: $season", null)
                    return@setMethodCallHandler
                }

                try {
                    setLauncherIcon(alias)
                    result.success(null)
                } catch (error: Exception) {
                    result.error("icon_update_failed", error.message, null)
                }
            }
    }

    private fun setLauncherIcon(activeAlias: String) {
        val packageManager = packageManager
        if ((applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
            iconAliases.values.forEach { alias ->
                packageManager.setComponentEnabledSetting(
                    ComponentName(this, "$packageName.$alias"),
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP,
                )
            }
            return
        }

        packageManager.setComponentEnabledSetting(
            ComponentName(this, "$packageName.$activeAlias"),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP,
        )
        iconAliases.values.forEach { alias ->
            if (alias == activeAlias) return@forEach
            val component = ComponentName(this, "$packageName.$alias")
            packageManager.setComponentEnabledSetting(
                component,
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP,
            )
        }
    }
}
