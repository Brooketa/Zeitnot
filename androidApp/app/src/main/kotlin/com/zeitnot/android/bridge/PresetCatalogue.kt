package com.zeitnot.android.bridge

import com.zeitnot.android.domain.Preset
import com.zeitnot.android.domain.PresetCatalogueContract
import com.zeitnot.android.domain.RulesetCategory

class PresetCatalogue : PresetCatalogueContract {

    init {
        SharedLibrary.ensureLoaded()
    }

    override val presets: List<Preset>
        get() = (0 until nativeCount()).map { index ->
            Preset(
                id = nativeId(index),
                category = RulesetCategory.entries[nativeCategory(index)],
                baseMinutes = nativeBaseMinutes(index),
                incrementSeconds = nativeIncrementSeconds(index)
            )
        }

    private external fun nativeCount(): Int
    private external fun nativeId(index: Int): String
    private external fun nativeCategory(index: Int): Int
    private external fun nativeBaseMinutes(index: Int): Int
    private external fun nativeIncrementSeconds(index: Int): Int

}
