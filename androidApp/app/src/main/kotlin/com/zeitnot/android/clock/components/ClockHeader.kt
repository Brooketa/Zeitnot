package com.zeitnot.android.clock.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.zeitnot.android.R
import com.zeitnot.android.clock.HeaderModel
import com.zeitnot.android.coreui.ColorPalette
import com.zeitnot.android.coreui.Spacing
import com.zeitnot.android.coreui.Typography
import com.zeitnot.android.domain.RulesetCategory

@Composable
fun ClockHeader(model: HeaderModel, onBack: () -> Unit, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(HEADER_HEIGHT),
        contentAlignment = Alignment.Center) {
        Ruleset(model = model)

        BackControl(
            onBack = onBack,
            modifier = Modifier.align(Alignment.CenterStart))

        BasicText(
            text = stringResource(R.string.move_number, model.moveNumber).uppercase(),
            style = Typography.label.copy(color = ColorPalette.textSecondary),
            modifier = Modifier.align(Alignment.CenterEnd))
    }
}

@Composable
private fun Ruleset(model: HeaderModel) {
    val dotColor by animateColorAsState(
        targetValue = if (model.isRunning) ColorPalette.accent else ColorPalette.textTertiary,
        animationSpec = tween(DOT_FADE_DURATION),
        label = "statusDot")

    Row(
        horizontalArrangement = Arrangement.spacedBy(Spacing.small),
        verticalAlignment = Alignment.CenterVertically) {
        Canvas(modifier = Modifier.size(DOT_DIAMETER)) {
            drawCircle(color = dotColor)
        }

        BasicText(
            text = stringResource(
                R.string.ruleset_title,
                stringResource(model.category.nameResource),
                model.baseMinutes,
                model.incrementSeconds).uppercase(),
            style = Typography.label.copy(color = ColorPalette.ink))
    }
}

@Composable
private fun BackControl(onBack: () -> Unit, modifier: Modifier = Modifier) {
    Canvas(
        modifier = modifier
            .size(BACK_DIAMETER)
            .clip(CircleShape)
            .background(ColorPalette.surface)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onBack)) {
        val centre = size.minDimension / 2
        val half = CHEVRON_SIZE.toPx() / 2

        drawLine(
            color = ColorPalette.ink,
            start = Offset(centre + half * 0.5f, centre - half),
            end = Offset(centre - half * 0.5f, centre),
            strokeWidth = CHEVRON_WIDTH.toPx(),
            cap = StrokeCap.Round)

        drawLine(
            color = ColorPalette.ink,
            start = Offset(centre - half * 0.5f, centre),
            end = Offset(centre + half * 0.5f, centre + half),
            strokeWidth = CHEVRON_WIDTH.toPx(),
            cap = StrokeCap.Round)
    }
}

private val RulesetCategory.nameResource: Int
    get() = when (this) {
        RulesetCategory.BULLET -> R.string.bullet_category
        RulesetCategory.BLITZ -> R.string.blitz_category
        RulesetCategory.RAPID -> R.string.rapid_category
        RulesetCategory.CLASSICAL -> R.string.classical_category
    }

private const val DOT_FADE_DURATION = 200

private val HEADER_HEIGHT = 44.dp
private val DOT_DIAMETER = 7.dp
private val BACK_DIAMETER = 44.dp
private val CHEVRON_SIZE = 20.dp
private val CHEVRON_WIDTH = 2.5.dp
