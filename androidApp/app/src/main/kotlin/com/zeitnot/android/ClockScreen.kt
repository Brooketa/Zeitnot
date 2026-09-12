package com.zeitnot.android

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
import com.zeitnot.android.coreui.ColorPalette
import com.zeitnot.android.coreui.Spacing
import com.zeitnot.android.coreui.Typography

@Composable
fun ClockScreen(configuration: GameConfiguration, onBack: () -> Unit) {
    val presenter = remember(configuration) { ClockPresenterNative(configuration) }

    DisposableEffect(presenter) {
        onDispose { presenter.close() }
    }

    var snapshot by remember { mutableStateOf(presenter.snapshot()) }

    LaunchedEffect(snapshot.isRunning) {
        while (snapshot.isRunning) {
            withFrameNanos { }

            snapshot = presenter.snapshot()
        }
    }

    LaunchedEffect(snapshot.didRequestBack) {
        if (snapshot.didRequestBack) onBack()
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(ColorPalette.background)
            .safeDrawingPadding(),
        verticalArrangement = Arrangement.spacedBy(Spacing.small)) {
        ClockHalf(
            face = snapshot.black,
            onPress = {
                presenter.press(ClockSide.BLACK)
                snapshot = presenter.snapshot()
            },
            modifier = Modifier.weight(1f))

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = Spacing.large),
            horizontalArrangement = Arrangement.spacedBy(Spacing.large)) {
            BasicText(
                text = stringResource(R.string.move_number, snapshot.moveNumber),
                style = Typography.label)

            if (snapshot.showPauseDialog) {
                ControlButton(textId = R.string.resume) {
                    presenter.resume()
                    snapshot = presenter.snapshot()
                }
            } else if (snapshot.canPause) {
                ControlButton(textId = R.string.pause) {
                    presenter.pause()
                    snapshot = presenter.snapshot()
                }
            }

            if (snapshot.canReset) {
                ControlButton(textId = R.string.reset) {
                    presenter.reset()
                    snapshot = presenter.snapshot()
                }
            }

            ControlButton(textId = R.string.back) {
                presenter.navigateBack()
                snapshot = presenter.snapshot()
            }
        }

        ClockHalf(
            face = snapshot.white,
            onPress = {
                presenter.press(ClockSide.WHITE)
                snapshot = presenter.snapshot()
            },
            modifier = Modifier.weight(1f))
    }

    if (snapshot.showResetDialog) {
        ResetDialog(
            onConfirm = {
                presenter.confirmReset()
                snapshot = presenter.snapshot()
            },
            onCancel = {
                presenter.cancelReset()
                snapshot = presenter.snapshot()
            })
    }
}

@Composable
private fun ClockHalf(face: ClockFace, onPress: () -> Unit, modifier: Modifier = Modifier) {
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

            else ->
                BasicText(text = face.reading.orEmpty(), style = Typography.clockDigits)
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
