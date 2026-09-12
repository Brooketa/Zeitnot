package com.zeitnot.android

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import com.zeitnot.android.coreui.ColorPalette
import com.zeitnot.android.coreui.Spacing
import com.zeitnot.android.coreui.Typography

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

@Composable
private fun SetupScreen(onStartGame: (GameConfiguration) -> Unit) {
    val presenter = remember { SetupPresenterNative() }

    DisposableEffect(presenter) {
        onDispose { presenter.close() }
    }

    var rulesets by remember { mutableStateOf(presenter.rulesets) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(ColorPalette.background)
            .safeDrawingPadding()
            .padding(Spacing.large),
        verticalArrangement = Arrangement.spacedBy(Spacing.small)) {
        rulesets.forEach { ruleset ->
            RulesetRow(
                ruleset = ruleset,
                onSelect = {
                    presenter.select(ruleset.id)
                    rulesets = presenter.rulesets
                })
        }

        BasicText(
            text = stringResource(R.string.start_game),
            style = Typography.buttonLabel,
            modifier = Modifier
                .fillMaxWidth()
                .clickable {
                    presenter.startGame()
                    presenter.requestedGame?.let(onStartGame)
                }
                .background(ColorPalette.accent)
                .padding(Spacing.large))
    }
}

@Composable
private fun RulesetRow(ruleset: Ruleset, onSelect: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onSelect)
            .background(if (ruleset.isSelected) ColorPalette.accentTint else ColorPalette.surface)
            .padding(Spacing.large),
        verticalArrangement = Arrangement.spacedBy(Spacing.extraSmall)) {
        BasicText(text = stringResource(ruleset.category.nameResource), style = Typography.label)

        BasicText(
            text = stringResource(
                R.string.ruleset_time_control,
                ruleset.baseMinutes,
                ruleset.incrementSeconds),
            style = Typography.title)
    }
}

private val RulesetCategory.nameResource: Int
    get() = when (this) {
        RulesetCategory.BULLET -> R.string.bullet_category
        RulesetCategory.BLITZ -> R.string.blitz_category
        RulesetCategory.RAPID -> R.string.rapid_category
        RulesetCategory.CLASSICAL -> R.string.classical_category
    }
