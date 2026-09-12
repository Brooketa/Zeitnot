package com.zeitnot.android.clock.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import com.zeitnot.android.R
import com.zeitnot.android.coreui.ColorPalette
import com.zeitnot.android.coreui.Spacing
import com.zeitnot.android.coreui.Typography
import com.zeitnot.android.domain.Player

@Composable
fun PauseDialog(playerToMove: Player, onResume: () -> Unit) {
    DialogContent {
        BasicText(
            text = stringResource(R.string.paused_title).uppercase(),
            style = Typography.largeTitle)

        BasicText(
            text = stringResource(playerToMove.toMoveResource).uppercase(),
            style = Typography.callout)

        DialogButton(title = stringResource(R.string.resume_button), isProminent = true, onClick = onResume)
    }
}

@Composable
fun ResetDialog(onConfirm: () -> Unit, onCancel: () -> Unit) {
    DialogContent {
        BasicText(
            text = stringResource(R.string.reset_dialog_title).uppercase(),
            style = Typography.largeTitle)

        BasicText(
            text = stringResource(R.string.reset_dialog_message),
            style = Typography.callout.copy(textAlign = TextAlign.Center))

        Row(horizontalArrangement = Arrangement.spacedBy(Spacing.medium)) {
            DialogButton(
                title = stringResource(R.string.cancel_button),
                isProminent = false,
                onClick = onCancel)

            DialogButton(
                title = stringResource(R.string.confirm_reset_button),
                isProminent = true,
                onClick = onConfirm)
        }
    }
}

@Composable
private fun DialogContent(content: @Composable ColumnScope.() -> Unit) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(Spacing.large),
        content = content)
}

@Composable
private fun DialogButton(title: String, isProminent: Boolean, onClick: () -> Unit) {
    BasicText(
        text = title.uppercase(),
        style = Typography.buttonLabel.copy(
            color = if (isProminent) ColorPalette.inkInverse else ColorPalette.ink),
        modifier = Modifier
            .clip(CircleShape)
            .background(if (isProminent) ColorPalette.accent else ColorPalette.surface)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onClick)
            .padding(horizontal = Spacing.extraLarge, vertical = Spacing.medium))
}

private val Player.toMoveResource: Int
    get() = when (this) {
        Player.WHITE -> R.string.white_to_move
        Player.BLACK -> R.string.black_to_move
    }
