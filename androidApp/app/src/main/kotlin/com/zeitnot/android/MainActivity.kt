package com.zeitnot.android

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.Saver
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import com.zeitnot.android.bridge.SwiftMainQueue
import com.zeitnot.android.clock.ClockScreen
import com.zeitnot.android.setup.GameConfiguration
import com.zeitnot.android.domain.RulesetCategory
import com.zeitnot.android.setup.SetupScreen

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        SwiftMainQueue.start()

        setContent {
            var game by rememberSaveable(stateSaver = GameConfigurationSaver) {
                mutableStateOf<GameConfiguration?>(null)
            }

            when (val configuration = game) {
                null -> SetupScreen(onStartGame = { game = it })
                else -> ClockScreen(configuration = configuration, onBack = { game = null })
            }
        }
    }

    override fun onDestroy() {
        SwiftMainQueue.stop()

        super.onDestroy()
    }

}

private val GameConfigurationSaver = Saver<GameConfiguration?, List<Any>>(
    save = { configuration ->
        configuration?.let { listOf(it.category.name, it.baseMinutes, it.incrementSeconds) } ?: emptyList()
    },
    restore = { values ->
        values.takeIf { it.isNotEmpty() }?.let {
            GameConfiguration(
                category = RulesetCategory.valueOf(it[0] as String),
                baseMinutes = it[1] as Int,
                incrementSeconds = it[2] as Int)
        }
    })
