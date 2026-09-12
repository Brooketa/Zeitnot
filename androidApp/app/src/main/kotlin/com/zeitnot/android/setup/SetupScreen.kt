package com.zeitnot.android.setup

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.Saver
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import com.zeitnot.android.LockOrientation
import com.zeitnot.android.R
import com.zeitnot.android.bridge.PresetCatalogue
import com.zeitnot.android.coreui.ColorPalette
import com.zeitnot.android.coreui.Spacing
import com.zeitnot.android.coreui.Typography
import com.zeitnot.android.domain.RulesetCategory
import com.zeitnot.android.setup.components.CardDivider
import com.zeitnot.android.setup.components.RulesetCell
import com.zeitnot.android.setup.components.RulesetCellModel
import com.zeitnot.android.setup.components.SectionCard
import com.zeitnot.android.setup.components.SectionHeader
import com.zeitnot.android.setup.components.StartGameBar

@Composable
fun SetupScreen(onStartGame: (GameConfiguration) -> Unit) {
    val presenter = rememberSaveable(saver = SetupPresenterSaver) { SetupPresenter(PresetCatalogue()) }

    var selectedRulesetId by rememberSaveable { mutableStateOf(presenter.selectedRulesetId) }

    LockOrientation(isLandscape = false)

    val rulesets = remember(selectedRulesetId) { presenter.rulesetModels }
    val configuration = remember(selectedRulesetId) { presenter.gameConfiguration }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(ColorPalette.background)
            .safeDrawingPadding()) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = Spacing.large)
                .padding(bottom = SCROLL_BOTTOM_INSET),
            verticalArrangement = Arrangement.spacedBy(Spacing.jumbo)) {
            Column(verticalArrangement = Arrangement.spacedBy(Spacing.extraSmall)) {
                BasicText(text = stringResource(R.string.set_the_clocks), style = Typography.largeTitle)

                BasicText(text = stringResource(R.string.choose_a_ruleset), style = Typography.callout)
            }

            Column(verticalArrangement = Arrangement.spacedBy(Spacing.medium)) {
                SectionHeader(title = stringResource(R.string.preset_rulesets))

                SectionCard {
                    rulesets.forEachIndexed { index, ruleset ->
                        if (index > 0) CardDivider()

                        RulesetCell(
                            model = ruleset.cellModel,
                            onSelect = {
                                presenter.select(ruleset.id)
                                selectedRulesetId = presenter.selectedRulesetId
                            })
                    }
                }
            }
        }

        StartGameBar(
            category = stringResource(configuration.category.nameResource),
            baseMinutes = configuration.baseMinutes,
            incrementSeconds = configuration.incrementSeconds,
            onStart = { onStartGame(configuration) },
            modifier = Modifier.align(Alignment.BottomCenter))
    }
}

private val RulesetModel.cellModel: RulesetCellModel
    @Composable
    get() = RulesetCellModel(
        id = id,
        category = stringResource(category.nameResource),
        description = stringResource(descriptionResource),
        baseMinutes = baseMinutes,
        incrementSeconds = incrementSeconds,
        isSelected = isSelected)

private val RulesetCategory.nameResource: Int
    get() = when (this) {
        RulesetCategory.BULLET -> R.string.bullet_category
        RulesetCategory.BLITZ -> R.string.blitz_category
        RulesetCategory.RAPID -> R.string.rapid_category
        RulesetCategory.CLASSICAL -> R.string.classical_category
    }

private val RulesetModel.descriptionResource: Int
    get() = when (id) {
        "bullet-1-0" -> R.string.bullet_1_0_description
        "blitz-3-2" -> R.string.blitz_3_2_description
        "blitz-5-0" -> R.string.blitz_5_0_description
        "rapid-10-0" -> R.string.rapid_10_0_description
        "rapid-15-10" -> R.string.rapid_15_10_description
        else -> R.string.classical_90_30_description
    }

private val SetupPresenterSaver = Saver<SetupPresenter, String>(
    save = { it.selectedRulesetId },
    restore = { id -> SetupPresenter(PresetCatalogue()).apply { select(id) } })

private val SCROLL_BOTTOM_INSET = Spacing.jumbo
