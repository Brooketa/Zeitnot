package com.zeitnot.android.clock.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.text.TextMeasurer
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.unit.sp
import com.zeitnot.android.clock.DialHands
import kotlin.math.cos
import kotlin.math.sin

@Composable
fun AnalogFace(
    hands: DialHands,
    faceColor: Color,
    minuteHandColor: Color,
    secondHandColor: Color,
    modifier: Modifier = Modifier
) {
    val minuteDegrees by animateFloatAsState(
        targetValue = hands.minuteDegrees,
        animationSpec = tween(durationMillis = SWEEP_DURATION),
        label = "minuteHand")
    val secondDegrees by animateFloatAsState(
        targetValue = hands.secondDegrees,
        animationSpec = tween(durationMillis = SWEEP_DURATION),
        label = "secondHand")
    val textMeasurer = rememberTextMeasurer()

    Canvas(modifier = modifier.aspectRatio(1f)) {
        val unit = size.minDimension / DESIGN_SIZE

        drawRim(color = faceColor, unit = unit)
        drawHourTicks(color = faceColor, unit = unit)
        drawNumerals(color = faceColor, unit = unit, textMeasurer = textMeasurer)

        rotate(degrees = -minuteDegrees) {
            drawMinuteHand(color = minuteHandColor, unit = unit)
        }

        rotate(degrees = -secondDegrees) {
            drawSecondHand(color = secondHandColor, unit = unit)
        }
    }
}

private fun DrawScope.drawRim(color: Color, unit: Float) {
    drawCircle(color = color, radius = RIM_RADIUS * unit, style = Stroke(width = RIM_WIDTH * unit))
}

private fun DrawScope.drawHourTicks(color: Color, unit: Float) {
    repeat(HOURS) { hour ->
        val angle = hour * RADIANS_PER_HOUR - QUARTER_TURN

        drawLine(
            color = color,
            start = centre + Offset(cos(angle) * TICK_OUTER * unit, sin(angle) * TICK_OUTER * unit),
            end = centre + Offset(cos(angle) * TICK_INNER * unit, sin(angle) * TICK_INNER * unit),
            strokeWidth = TICK_WIDTH * unit,
            cap = StrokeCap.Round)
    }
}

private fun DrawScope.drawNumerals(color: Color, unit: Float, textMeasurer: TextMeasurer) {
    val style = TextStyle(color = color, fontSize = (NUMERAL_SIZE * unit).toSp(), fontWeight = FontWeight.Bold)

    repeat(HOURS) { hour ->
        val numeral = if (hour == 0) HOURS else hour
        val angle = hour * RADIANS_PER_HOUR - QUARTER_TURN
        val measured = textMeasurer.measure(numeral.toString(), style)
        val position = centre + Offset(cos(angle) * NUMERAL_RADIUS * unit, sin(angle) * NUMERAL_RADIUS * unit)

        drawText(
            textLayoutResult = measured,
            topLeft = Offset(
                position.x - measured.size.width / 2,
                position.y - measured.size.height / 2))
    }
}

private fun DrawScope.drawMinuteHand(color: Color, unit: Float) {
    drawLine(
        color = color,
        start = centre,
        end = centre - Offset(0f, MINUTE_HAND_LENGTH * unit),
        strokeWidth = MINUTE_HAND_WIDTH * unit,
        cap = StrokeCap.Round)

    drawCircle(color = color, radius = HUB_RADIUS * unit, center = centre)
}

private fun DrawScope.drawSecondHand(color: Color, unit: Float) {
    drawLine(
        color = color,
        start = centre + Offset(0f, SECOND_HAND_TAIL * unit),
        end = centre - Offset(0f, SECOND_HAND_LENGTH * unit),
        strokeWidth = SECOND_HAND_WIDTH * unit,
        cap = StrokeCap.Round)
}

private val DrawScope.centre: Offset
    get() = Offset(size.width / 2, size.height / 2)

private const val SWEEP_DURATION = 200
private const val DESIGN_SIZE = 200f
private const val HOURS = 12
private const val RIM_RADIUS = 95f
private const val RIM_WIDTH = 2f
private const val TICK_OUTER = 88f
private const val TICK_INNER = 81f
private const val TICK_WIDTH = 2.5f
private const val NUMERAL_SIZE = 15f
private const val NUMERAL_RADIUS = 56f
private const val MINUTE_HAND_LENGTH = 42.5f
private const val MINUTE_HAND_WIDTH = 5f
private const val HUB_RADIUS = 7.5f
private const val SECOND_HAND_LENGTH = 74f
private const val SECOND_HAND_TAIL = 14f
private const val SECOND_HAND_WIDTH = 2f
private const val RADIANS_PER_HOUR = (2 * Math.PI / HOURS).toFloat()
private const val QUARTER_TURN = (Math.PI / 2).toFloat()
