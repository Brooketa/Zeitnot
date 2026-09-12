package com.zeitnot.android.coreui

import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

object Spacing {

    val extraSmall = 4.dp
    val small = 8.dp
    val medium = 12.dp
    val large = 16.dp
    val extraLarge = 20.dp
    val jumbo = 24.dp

    fun grid(multiplier: Float): Dp = extraSmall * multiplier

}
