package com.zeitnot.android.clock.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.unit.dp
import com.zeitnot.android.coreui.ColorPalette

@Composable
fun FullScreenPresentation(
    isPresented: Boolean,
    presented: @Composable () -> Unit,
    content: @Composable () -> Unit
) {
    val blurRadius by animateDpAsState(
        targetValue = if (isPresented) BLUR_RADIUS else 0.dp,
        animationSpec = tween(DURATION),
        label = "presentationBlur")

    Box(modifier = Modifier.fillMaxSize()) {
        Box(modifier = Modifier.blur(blurRadius)) {
            content()
        }

        AnimatedVisibility(
            visible = isPresented,
            enter = fadeIn(tween(DURATION)),
            exit = fadeOut(tween(DURATION))) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(ColorPalette.background.copy(alpha = SCRIM_OPACITY))
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                        onClick = {}),
                contentAlignment = Alignment.Center) {
                presented()
            }
        }
    }
}

private const val SCRIM_OPACITY = 0.8f
private const val DURATION = 250

private val BLUR_RADIUS = 8.dp
