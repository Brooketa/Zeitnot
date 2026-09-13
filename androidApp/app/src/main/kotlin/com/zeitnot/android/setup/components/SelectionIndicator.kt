package com.zeitnot.android.setup.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp
import com.zeitnot.android.coreui.ColorPalette

@Composable
fun SelectionIndicator(isSelected: Boolean, modifier: Modifier = Modifier) {
    Canvas(modifier = modifier.size(DIAMETER)) {
        val radius = size.minDimension / 2
        val ring = RING_WIDTH.toPx()

        if (isSelected) {
            drawCircle(color = ColorPalette.accent, radius = radius)
            drawCheckmark()
        } else {
            drawCircle(
                color = ColorPalette.controlBorder,
                radius = radius - ring / 2,
                style = Stroke(width = ring))
        }
    }
}

private fun androidx.compose.ui.graphics.drawscope.DrawScope.drawCheckmark() {
    val width = size.width
    val stroke = Stroke(width = CHECK_WIDTH.toPx(), cap = StrokeCap.Round)

    drawLine(
        color = ColorPalette.inkInverse,
        start = Offset(width * 0.30f, width * 0.52f),
        end = Offset(width * 0.44f, width * 0.66f),
        strokeWidth = stroke.width,
        cap = StrokeCap.Round)

    drawLine(
        color = ColorPalette.inkInverse,
        start = Offset(width * 0.44f, width * 0.66f),
        end = Offset(width * 0.70f, width * 0.36f),
        strokeWidth = stroke.width,
        cap = StrokeCap.Round)
}

private val DIAMETER = 26.dp
private val RING_WIDTH = 2.dp
private val CHECK_WIDTH = 2.5.dp
