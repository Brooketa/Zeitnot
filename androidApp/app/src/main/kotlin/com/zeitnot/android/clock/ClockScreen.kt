package com.zeitnot.android.clock

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
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
import com.zeitnot.android.LockOrientation
import com.zeitnot.android.bridge.GameService
import com.zeitnot.android.clock.components.ClockFaceCard
import com.zeitnot.android.clock.components.ClockHeader
import com.zeitnot.android.clock.components.ControlBar
import com.zeitnot.android.clock.components.FullScreenPresentation
import com.zeitnot.android.clock.components.PauseDialog
import com.zeitnot.android.clock.components.ResetDialog
import com.zeitnot.android.coreui.ColorPalette
import com.zeitnot.android.coreui.Spacing
import com.zeitnot.android.domain.Player
import com.zeitnot.android.setup.GameConfiguration

@Composable
fun ClockScreen(configuration: GameConfiguration, onBack: () -> Unit) {
    val presenter = remember(configuration) {
        ClockPresenter(
            configuration = configuration,
            game = GameService(configuration.baseMinutes, configuration.incrementSeconds))
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

    LockOrientation(isLandscape = true)

    BackHandler(enabled = true) {}

    FullScreenPresentation(
        isPresented = model.showPauseDialog || model.showResetDialog,
        presented = {
            when {
                model.showPauseDialog -> PauseDialog(
                    playerToMove = model.playerToMove,
                    onResume = {
                        presenter.resume()
                        model = presenter.model()
                    })

                model.showResetDialog -> ResetDialog(
                    onConfirm = {
                        presenter.confirmReset()
                        model = presenter.model()
                    },
                    onCancel = {
                        presenter.cancelReset()
                        model = presenter.model()
                    })
            }
        }) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(ColorPalette.background)
                .safeDrawingPadding()
                .padding(horizontal = Spacing.large, vertical = Spacing.small),
            verticalArrangement = Arrangement.spacedBy(Spacing.medium)) {
            ClockHeader(model = model.header, onBack = onBack)

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f),
                horizontalArrangement = Arrangement.spacedBy(Spacing.medium)) {
                ClockFaceCard(
                    model = model.white,
                    displayMode = model.displayMode,
                    onPress = { model = presenter.pressed(Player.WHITE) },
                    modifier = Modifier.weight(1f))

                ClockFaceCard(
                    model = model.black,
                    displayMode = model.displayMode,
                    onPress = { model = presenter.pressed(Player.BLACK) },
                    modifier = Modifier.weight(1f))
            }

            ControlBar(
                model = model.controlBar,
                displayMode = model.displayMode,
                onSelectDisplayMode = { mode ->
                    presenter.select(mode)
                    model = presenter.model()
                },
                onPause = {
                    presenter.pause()
                    model = presenter.model()
                },
                onReset = {
                    presenter.reset()
                    model = presenter.model()
                },
                modifier = Modifier.align(Alignment.CenterHorizontally))
        }
    }
}

private fun ClockPresenter.pressed(side: Player): ClockModel {
    press(side)

    return model()
}
