package com.zeitnot.android.setup.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.zeitnot.android.R
import com.zeitnot.android.coreui.ColorPalette
import com.zeitnot.android.coreui.Spacing
import com.zeitnot.android.coreui.Typography

@Composable
fun StartGameBar(
    category: String,
    baseMinutes: Int,
    incrementSeconds: Int,
    onStart: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(Brush.verticalGradient(listOf(Color.Transparent, ColorPalette.background)))
            .windowInsetsPadding(WindowInsets.navigationBars)
            .padding(
                start = Spacing.large,
                end = Spacing.large,
                top = SCRIM_HEIGHT,
                bottom = Spacing.extraSmall)) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(CircleShape)
                .clickable(onClick = onStart)
                .background(ColorPalette.accent)
                .padding(horizontal = Spacing.extraLarge, vertical = Spacing.medium),
            horizontalArrangement = Arrangement.spacedBy(Spacing.large),
            verticalAlignment = Alignment.CenterVertically) {
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(Spacing.extraSmall)) {
                BasicText(
                    text = stringResource(R.string.start_game).uppercase(),
                    style = Typography.buttonLabel)

                BasicText(
                    text = stringResource(
                        R.string.selected_ruleset,
                        category,
                        baseMinutes,
                        incrementSeconds),
                    style = Typography.footnote.copy(color = ColorPalette.inkInverse))
            }

            ForwardArrow()
        }
    }
}

@Composable
private fun ForwardArrow() {
    Canvas(modifier = Modifier.size(ARROW_DIAMETER)) {
        val centre = size.minDimension / 2
        val stroke = ARROW_STROKE.toPx()
        val half = ARROW_SIZE.toPx() / 2

        drawCircle(color = ColorPalette.accentRaised, radius = centre)

        drawLine(
            color = ColorPalette.inkInverse,
            start = Offset(centre - half, centre),
            end = Offset(centre + half, centre),
            strokeWidth = stroke,
            cap = StrokeCap.Round)

        drawLine(
            color = ColorPalette.inkInverse,
            start = Offset(centre + half - half * 0.6f, centre - half * 0.6f),
            end = Offset(centre + half, centre),
            strokeWidth = stroke,
            cap = StrokeCap.Round)

        drawLine(
            color = ColorPalette.inkInverse,
            start = Offset(centre + half - half * 0.6f, centre + half * 0.6f),
            end = Offset(centre + half, centre),
            strokeWidth = stroke,
            cap = StrokeCap.Round)
    }
}

private val SCRIM_HEIGHT = 32.dp
private val ARROW_DIAMETER = 36.dp
private val ARROW_SIZE = 14.dp
private val ARROW_STROKE = 2.dp
