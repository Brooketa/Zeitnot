package com.zeitnot.android.clock.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import com.zeitnot.android.R
import com.zeitnot.android.clock.ControlBarModel
import com.zeitnot.android.clock.DisplayMode
import com.zeitnot.android.coreui.ColorPalette
import com.zeitnot.android.coreui.Spacing
import androidx.compose.ui.unit.dp
import com.zeitnot.android.coreui.Typography

@Composable
fun ControlBar(
    model: ControlBarModel,
    displayMode: DisplayMode,
    onSelectDisplayMode: (DisplayMode) -> Unit,
    onPause: () -> Unit,
    onReset: () -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(Spacing.medium),
        verticalAlignment = Alignment.CenterVertically) {
        DisplayModeControl(displayMode = displayMode, onSelect = onSelectDisplayMode)

        ControlButton(
            title = stringResource(R.string.pause_button),
            isEnabled = model.canPause,
            onClick = onPause)

        ControlButton(
            title = stringResource(R.string.reset_button),
            isEnabled = model.canReset,
            onClick = onReset)
    }
}

@Composable
private fun DisplayModeControl(displayMode: DisplayMode, onSelect: (DisplayMode) -> Unit) {
    Row(
        modifier = Modifier
            .clip(CircleShape)
            .background(ColorPalette.surfaceMuted)
            .padding(Spacing.extraSmall),
        horizontalArrangement = Arrangement.spacedBy(Spacing.extraSmall)) {
        DisplayModeSegment(
            title = stringResource(R.string.digital_mode),
            isSelected = displayMode == DisplayMode.DIGITAL,
            onClick = { onSelect(DisplayMode.DIGITAL) })

        DisplayModeSegment(
            title = stringResource(R.string.analog_mode),
            isSelected = displayMode == DisplayMode.ANALOG,
            onClick = { onSelect(DisplayMode.ANALOG) })
    }
}

@Composable
private fun DisplayModeSegment(title: String, isSelected: Boolean, onClick: () -> Unit) {
    BasicText(
        text = title.uppercase(),
        style = Typography.label.copy(
            color = if (isSelected) ColorPalette.inkInverse else ColorPalette.textSecondary),
        modifier = Modifier
            .clip(CircleShape)
            .background(if (isSelected) ColorPalette.ink else ColorPalette.surfaceMuted)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onClick)
            .padding(horizontal = Spacing.medium, vertical = Spacing.small))
}

@Composable
private fun ControlButton(title: String, isEnabled: Boolean, onClick: () -> Unit) {
    BasicText(
        text = title.uppercase(),
        style = Typography.buttonLabel.copy(color = ColorPalette.ink),
        modifier = Modifier
            .alpha(if (isEnabled) 1f else DISABLED_OPACITY)
            .clip(CircleShape)
            .background(ColorPalette.surface)
            .border(width = BORDER_WIDTH, color = ColorPalette.controlBorder, shape = CircleShape)
            .clickable(
                enabled = isEnabled,
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onClick)
            .padding(horizontal = Spacing.extraLarge, vertical = Spacing.medium))
}

private const val DISABLED_OPACITY = 0.4f

private val BORDER_WIDTH = 1.dp
