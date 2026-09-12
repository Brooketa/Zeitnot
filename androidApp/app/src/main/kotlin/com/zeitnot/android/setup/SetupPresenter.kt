package com.zeitnot.android.setup

import com.zeitnot.android.domain.Preset
import com.zeitnot.android.domain.PresetCatalogueContract
import com.zeitnot.android.domain.RulesetCategory

data class RulesetModel(
    val id: String,
    val category: RulesetCategory,
    val baseMinutes: Int,
    val incrementSeconds: Int,
    val isSelected: Boolean
)

data class GameConfiguration(
    val category: RulesetCategory,
    val baseMinutes: Int,
    val incrementSeconds: Int
)

class SetupPresenter(catalogue: PresetCatalogueContract) {

    private val presets: List<Preset> = catalogue.presets
    private var selection: Preset = presets.first()

    val rulesetModels: List<RulesetModel>
        get() = presets.map { preset ->
            RulesetModel(
                id = preset.id,
                category = preset.category,
                baseMinutes = preset.baseMinutes,
                incrementSeconds = preset.incrementSeconds,
                isSelected = preset.id == selection.id
            )
        }

    val gameConfiguration: GameConfiguration
        get() = GameConfiguration(
            category = selection.category,
            baseMinutes = selection.baseMinutes,
            incrementSeconds = selection.incrementSeconds
        )

    fun select(id: String) {
        selection = presets.firstOrNull { it.id == id } ?: return
    }

}
