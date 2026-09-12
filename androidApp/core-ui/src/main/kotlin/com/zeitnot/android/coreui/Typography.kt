package com.zeitnot.android.coreui

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

object Typography {

    val clockDigits = style(
        size = 76,
        weight = FontWeight.Bold,
        tracking = -2.3f,
        hasTabularFigures = true,
        color = ColorPalette.ink)

    val largeTitle = style(size = 32, weight = FontWeight.Bold, tracking = -0.8f, color = ColorPalette.ink)
    val title = style(size = 22, weight = FontWeight.ExtraBold, tracking = -0.6f, color = ColorPalette.ink)
    val headline = style(size = 19, weight = FontWeight.Bold, color = ColorPalette.ink)
    val body = style(size = 17, weight = FontWeight.SemiBold, color = ColorPalette.ink)
    val calloutBold = style(size = 15, weight = FontWeight.SemiBold, color = ColorPalette.ink)
    val buttonLabel = style(size = 15, weight = FontWeight.SemiBold, tracking = 0.6f, color = ColorPalette.inkInverse)
    val callout = style(size = 15, weight = FontWeight.Normal, color = ColorPalette.textSecondary)
    val footnote = style(size = 13, weight = FontWeight.Normal, color = ColorPalette.textSecondary)
    val label = style(size = 12, weight = FontWeight.SemiBold, tracking = 1.4f, color = ColorPalette.textTertiary)
    val playerName = style(size = 12, weight = FontWeight.Bold, tracking = 2.4f, color = ColorPalette.textSecondary)
    val micro = style(size = 10, weight = FontWeight.SemiBold, tracking = 1.8f, color = ColorPalette.accent)

    private fun style(
        size: Int,
        weight: FontWeight,
        tracking: Float = 0f,
        hasTabularFigures: Boolean = false,
        color: Color
    ) = TextStyle(
        fontSize = size.sp,
        fontWeight = weight,
        letterSpacing = tracking.sp,
        fontFeatureSettings = if (hasTabularFigures) TABULAR_FIGURES else null,
        color = color)

}

private const val TABULAR_FIGURES = "tnum"
