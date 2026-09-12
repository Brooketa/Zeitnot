package com.zeitnot.android.clock

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.withFrameNanos
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import com.zeitnot.android.R
import com.zeitnot.android.coreui.ColorPalette
import com.zeitnot.android.coreui.Spacing
import com.zeitnot.android.coreui.Typography
import com.zeitnot.android.domain.Player
import com.zeitnot.android.bridge.GameService
import com.zeitnot.android.setup.GameConfiguration

@Composable
fun ClockScreen(configuration: GameConfiguration, onBack: () -> Unit) {
    val presenter = remember(configuration) {
        ClockPresenter(GameService(configuration.baseMinutes, configuration.incrementSeconds))
    }

    DisposableEffect(presenter) {
        onDispose { presenter.close() }
    }

    var model by remember { mutableStateOf(presenter.model()) }

    LaunchedEffect(model.isRunning) {
        while (model.isRunning) {
            withFrameNanos { }

            model = presenter.model()
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(ColorPalette.background)
            .safeDrawingPadding(),
        verticalArrangement = Arrangement.spacedBy(Spacing.small)) {
        ClockHalf(
            face = model.black,
            onPress = {
                presenter.press(Player.BLACK)
                model = presenter.model()
            },
            modifier = Modifier.weight(1f))

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = Spacing.large),
            horizontalArrangement = Arrangement.spacedBy(Spacing.large)) {
            BasicText(
                text = stringResource(R.string.move_number, model.moveNumber),
                style = Typography.label)

            if (model.showPauseDialog) {
                ControlButton(textId = R.string.resume) {
                    presenter.resume()
                    model = presenter.model()
                }
            } else if (model.canPause) {
                ControlButton(textId = R.string.pause) {
                    presenter.pause()
                    model = presenter.model()
                }
            }

            if (model.canReset) {
                ControlButton(textId = R.string.reset) {
                    presenter.reset()
                    model = presenter.model()
                }
            }

            ControlButton(textId = R.string.back, onClick = onBack)
        }

        ClockHalf(
            face = model.white,
            onPress = {
                presenter.press(Player.WHITE)
                model = presenter.model()
            },
            modifier = Modifier.weight(1f))
    }

    if (model.showResetDialog) {
        ResetDialog(
            onConfirm = {
                presenter.confirmReset()
                model = presenter.model()
            },
            onCancel = {
                presenter.cancelReset()
                model = presenter.model()
            })
    }
}

@Composable
private fun ClockHalf(face: ClockFaceModel, onPress: () -> Unit, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .background(face.state.background)
            .clickable(onClick = onPress),
        contentAlignment = Alignment.Center) {
        when (face.state) {
            ClockFaceState.AWAITING_START ->
                BasicText(text = stringResource(R.string.press_to_start), style = Typography.label)

            ClockFaceState.FLAGGED ->
                BasicText(text = stringResource(R.string.flag_fell), style = Typography.label)

            else -> BasicText(text = face.reading, style = Typography.clockDigits)
        }
    }
}

@Composable
private fun ResetDialog(onConfirm: () -> Unit, onCancel: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(ColorPalette.surface)
            .padding(Spacing.jumbo),
        verticalArrangement = Arrangement.spacedBy(Spacing.large, Alignment.CenterVertically)) {
        ControlButton(textId = R.string.confirm_reset, onClick = onConfirm)

        ControlButton(textId = R.string.cancel_reset, onClick = onCancel)
    }
}

@Composable
private fun ControlButton(textId: Int, onClick: () -> Unit) {
    BasicText(
        text = stringResource(textId),
        style = Typography.label,
        modifier = Modifier
            .clickable(onClick = onClick)
            .padding(Spacing.small))
}

private val ClockFaceState.background
    get() = when (this) {
        ClockFaceState.TO_MOVE -> ColorPalette.surface
        ClockFaceState.LOW_TIME -> ColorPalette.accentTint
        ClockFaceState.FLAGGED -> ColorPalette.accent
        else -> ColorPalette.surfaceMuted
    }
