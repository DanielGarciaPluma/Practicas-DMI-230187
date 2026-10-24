
package com.example.toktik

import android.content.ComponentName
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val appIconChannel = "com.example.toktik/app_icon"
    private var isActivityStarted = false
    private var pendingIconAlias: String? = null

    private val iconAliases = mapOf(
        "normal" to "MainActivityNormal",
        "halloween" to "MainActivityHalloween",
        "christmas" to "MainActivityChristmas",
        "valentines" to "MainActivityValentines"
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            appIconChannel
        ).setMethodCallHandler { call, result ->

            if (call.method != "setSeasonIcon") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val season = call.argument<String>("season")
            val alias = iconAliases[season]

            if (alias == null) {
                result.error(
                    "invalid_season",
                    "Temporada desconocida: $season",
                    null
                )
                return@setMethodCallHandler
            }

            if (isActivityStarted) {
                pendingIconAlias = alias
                result.success(true)
                return@setMethodCallHandler
            }

            try {
                setLauncherIcon(alias)
                result.success(true)
            } catch (error: Exception) {
                result.error(
                    "icon_update_failed",
                    error.message ?: "No se pudo cambiar el icono",
                    null
                )
            }
        }
    }

    override fun onStart() {
        super.onStart()
        isActivityStarted = true
    }

    override fun onStop() {
        super.onStop()
        isActivityStarted = false

        val alias = pendingIconAlias ?: return
        try {
            setLauncherIcon(alias)
            pendingIconAlias = null
        } catch (error: Exception) {
            Log.e("MainActivity", "Could not apply the pending launcher icon", error)
        }
    }

    private fun setLauncherIcon(activeAlias: String) {
        val pm = packageManager

        // Preparar el estado deseado de cada alias.
        val settings = iconAliases.values.map { alias ->
            val component = ComponentName(
                this,
                "$packageName.$alias"
            )

            val state = if (alias == activeAlias) {
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            } else {
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED
            }

            PackageManager.ComponentEnabledSetting(
                component,
                state,
                PackageManager.DONT_KILL_APP
            )
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Android 13 o superior: cambiar los alias en una operación.
            pm.setComponentEnabledSettings(settings)
        } else {
            // Primero deshabilitar los alias que no corresponden.
            iconAliases.values
                .filter { it != activeAlias }
                .forEach { alias ->
                    pm.setComponentEnabledSetting(
                        ComponentName(this, "$packageName.$alias"),
                        PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                        PackageManager.DONT_KILL_APP
                    )
                }

            // Después habilitar el alias seleccionado.
            pm.setComponentEnabledSetting(
                ComponentName(this, "$packageName.$activeAlias"),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )
        }

        // Comprobar que el alias elegido quedó habilitado.
        val selectedComponent = ComponentName(
            this,
            "$packageName.$activeAlias"
        )

        check(
            pm.getComponentEnabledSetting(selectedComponent) ==
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
        ) {
            "No se pudo habilitar el icono: $activeAlias"
        }
    }
}
