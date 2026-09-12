package com.zeitnot.android.domain


enum class RulesetCategory {
    BULLET,
    BLITZ,
    RAPID,
    CLASSICAL
}

data class Preset(
    val id: String,
    val category: RulesetCategory,
    val baseMinutes: Int,
    val incrementSeconds: Int
)

interface PresetCatalogueContract {

    val presets: List<Preset>

}
