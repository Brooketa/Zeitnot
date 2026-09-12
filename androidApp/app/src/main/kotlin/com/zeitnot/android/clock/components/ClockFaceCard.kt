package com.zeitnot.android.clock.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.zeitnot.android.R
import com.zeitnot.android.clock.ClockFaceModel
import com.zeitnot.android.clock.DisplayMode
import com.zeitnot.android.coreui.ColorPalette
import com.zeitnot.android.coreui.Spacing
import com.zeitnot.android.coreui.Typography
import com.zeitnot.android.domain.ClockStatus
import com.zeitnot.android.domain.Player

@Composable
fun ClockFaceCard(
    model: ClockFaceModel,
    displayMode: DisplayMode,
    onPress: () -> Unit,
    modifier: Modifier = Modifier
) {
    val appearance = model.status.appearance
    val background by animateColorAsState(
        targetValue = appearance.background,
        animationSpec = tween(STATE_CHANGE_DURATION),
        label = "cardBackground")

    Column(
        modifier = modifier
            .fillMaxHeight()
            .clip(RoundedCornerShape(CORNER_RADIUS))
            .background(background)
            .turnRing(appearance)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onPress)
            .padding(vertical = Spacing.large, horizontal = Spacing.medium),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(Spacing.small)) {
        BasicText(
            text = stringResource(model.side.nameResource).uppercase(),
            style = Typography.playerName.copy(color = appearance.name))

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f),
            contentAlignment = Alignment.Center) {
            when (displayMode) {
                DisplayMode.DIGITAL ->
                    BasicText(
                        text = model.reading,
                        style = Typography.clockDigits.copy(color = appearance.face))

                DisplayMode.ANALOG ->
                    AnalogFace(
                        hands = model.hands,
                        faceColor = appearance.face,
                        minuteHandColor = appearance.face,
                        secondHandColor = appearance.secondHand,
                        modifier = Modifier.fillMaxHeight(DIAL_HEIGHT_FRACTION))
            }
        }

        BasicText(
            text = model.caption,
            style = Typography.label.copy(color = appearance.name, textAlign = TextAlign.Center),
            modifier = Modifier.fillMaxWidth())
    }
}

@Composable
private fun Modifier.turnRing(appearance: FaceAppearance): Modifier {
    if (!appearance.hasRing) return this

    val transition = rememberInfiniteTransition(label = "ring")
    val alpha by transition.animateFloat(
        initialValue = if (appearance.pulses) RING_PULSE_MINIMUM else 1f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(PULSE_DURATION),
            repeatMode = RepeatMode.Reverse),
        label = "ringAlpha")

    return border(
        width = RING_WIDTH,
        color = ColorPalette.accent.copy(alpha = if (appearance.pulses) alpha else 1f),
        shape = RoundedCornerShape(CORNER_RADIUS))
}

private data class FaceAppearance(
    val background: Color,
    val name: Color,
    val face: Color,
    val secondHand: Color,
    val hasRing: Boolean,
    val pulses: Boolean
)

private val ClockStatus.appearance: FaceAppearance
    get() = when (this) {
        ClockStatus.AWAITING_START, ClockStatus.WAITING -> FaceAppearance(
            background = ColorPalette.surface,
            name = ColorPalette.textSecondary,
            face = ColorPalette.textSecondary,
            secondHand = ColorPalette.textSecondary,
            hasRing = false,
            pulses = false)

        ClockStatus.TO_MOVE -> FaceAppearance(
            background = ColorPalette.surface,
            name = ColorPalette.accent,
            face = ColorPalette.ink,
            secondHand = ColorPalette.accent,
            hasRing = true,
            pulses = false)

        ClockStatus.LOW_TIME -> FaceAppearance(
            background = ColorPalette.surface,
            name = ColorPalette.accent,
            face = ColorPalette.ink,
            secondHand = ColorPalette.accent,
            hasRing = true,
            pulses = true)

        ClockStatus.FLAGGED -> FaceAppearance(
            background = ColorPalette.accent,
            name = ColorPalette.inkInverse,
            face = ColorPalette.inkInverse,
            secondHand = ColorPalette.inkInverse,
            hasRing = false,
            pulses = false)
    }

private val ClockFaceModel.caption: String
    @Composable
    get() = when {
        status == ClockStatus.FLAGGED -> stringResource(R.string.flag_fell).uppercase()
        status == ClockStatus.AWAITING_START && side == Player.BLACK ->
            stringResource(R.string.press_to_start).uppercase()
        else -> ""
    }

private val Player.nameResource: Int
    get() = when (this) {
        Player.WHITE -> R.string.white_player
        Player.BLACK -> R.string.black_player
    }

private const val STATE_CHANGE_DURATION = 200
private const val PULSE_DURATION = 600
private const val RING_PULSE_MINIMUM = 0.2f
private const val DIAL_HEIGHT_FRACTION = 0.95f

private val CORNER_RADIUS = 26.dp
private val RING_WIDTH = 3.dp
