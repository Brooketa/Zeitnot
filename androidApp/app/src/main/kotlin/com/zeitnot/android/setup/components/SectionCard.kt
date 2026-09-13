package com.zeitnot.android.setup.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.zeitnot.android.coreui.ColorPalette

@Composable
fun SectionCard(modifier: Modifier = Modifier, content: @Composable ColumnScope.() -> Unit) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(CORNER_RADIUS))
            .background(ColorPalette.surface),
        content = content)
}

@Composable
fun CardDivider() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .height(DIVIDER_HEIGHT)
            .background(ColorPalette.separator)) {}
}

private val CORNER_RADIUS = 16.dp
private val DIVIDER_HEIGHT = 1.dp
