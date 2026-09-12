package com.zeitnot.android

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import com.zeitnot.android.bridge.SwiftMainQueue
import com.zeitnot.android.clock.ClockScreen
import com.zeitnot.android.setup.GameConfiguration
import com.zeitnot.android.setup.SetupScreen

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        SwiftMainQueue.start()

        setContent {
            var game by remember { mutableStateOf<GameConfiguration?>(null) }

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
