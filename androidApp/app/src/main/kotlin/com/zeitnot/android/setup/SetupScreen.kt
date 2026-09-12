package com.zeitnot.android.setup

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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import com.zeitnot.android.R
import com.zeitnot.android.coreui.ColorPalette
import com.zeitnot.android.coreui.Spacing
import com.zeitnot.android.coreui.Typography
import com.zeitnot.android.domain.RulesetCategory
import com.zeitnot.android.bridge.PresetCatalogue

@Composable
fun SetupScreen(onStartGame: (GameConfiguration) -> Unit) {
    val presenter = remember { SetupPresenter(PresetCatalogue()) }

    var rulesets by remember { mutableStateOf(presenter.rulesetModels) }

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
                    rulesets = presenter.rulesetModels
                })
        }

        BasicText(
            text = stringResource(R.string.start_game),
            style = Typography.buttonLabel,
            modifier = Modifier
                .fillMaxWidth()
                .clickable { onStartGame(presenter.gameConfiguration) }
                .background(ColorPalette.accent)
                .padding(Spacing.large))
    }
}

@Composable
private fun RulesetRow(ruleset: RulesetModel, onSelect: () -> Unit) {
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
