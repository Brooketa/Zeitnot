package com.zeitnot.android.clock

import com.zeitnot.android.domain.ClockStatus
import com.zeitnot.android.domain.GameServiceContract
import com.zeitnot.android.domain.Player

enum class ClockFaceState {
    AWAITING_START,
    TO_MOVE,
    LOW_TIME,
    WAITING,
    FLAGGED
}

enum class DisplayMode {
    DIGITAL,
    ANALOG
}

data class DialHands(val minuteDegrees: Float, val secondDegrees: Float)

data class ClockFaceModel(
    val side: Player,
    val state: ClockFaceState,
    val reading: String,
    val hands: DialHands
)

data class ClockModel(
    val white: ClockFaceModel,
    val black: ClockFaceModel,
    val moveNumber: Int,
    val canPause: Boolean,
    val canReset: Boolean,
    val isRunning: Boolean,
    val showPauseDialog: Boolean,
    val showResetDialog: Boolean,
    val playerToMove: Player
)

class ClockPresenter(private val game: GameServiceContract) : AutoCloseable {

    var displayMode: DisplayMode = DisplayMode.DIGITAL

    private var showResetDialog = false

    fun model(): ClockModel {
        val snapshot = game.snapshot()

        return ClockModel(
            white = faceModel(Player.WHITE),
            black = faceModel(Player.BLACK),
            moveNumber = snapshot.moveNumber,
            canPause = snapshot.isRunning,
            canReset = snapshot.isRunning || snapshot.isFinished,
            isRunning = snapshot.isRunning,
            showPauseDialog = snapshot.isPaused,
            showResetDialog = showResetDialog,
            playerToMove = snapshot.playerToMove
        )
    }

    fun press(side: Player) = game.press(side)

    fun pause() = game.pause()

    fun resume() = game.resume()

    fun reset() {
        if (game.snapshot().isInProgress) {
            showResetDialog = true
            return
        }

        game.reset()
    }

    fun confirmReset() {
        game.reset()
        showResetDialog = false
    }

    fun cancelReset() {
        showResetDialog = false
    }

    override fun close() = game.close()

    private fun faceModel(player: Player): ClockFaceModel {
        val clock = game.snapshot()[player]

        return ClockFaceModel(
            side = player,
            state = faceState(clock.status),
            reading = game.reading(player),
            hands = hands(clock.remainingMillis)
        )
    }

    private fun faceState(status: ClockStatus) = when (status) {
        ClockStatus.AWAITING_START -> ClockFaceState.AWAITING_START
        ClockStatus.TO_MOVE -> ClockFaceState.TO_MOVE
        ClockStatus.LOW_TIME -> ClockFaceState.LOW_TIME
        ClockStatus.WAITING -> ClockFaceState.WAITING
        ClockStatus.FLAGGED -> ClockFaceState.FLAGGED
    }

    private fun hands(remainingMillis: Long): DialHands {
        val seconds = remainingMillis / MILLISECONDS_PER_SECOND

        return DialHands(
            minuteDegrees = seconds / SECONDS_PER_HOUR * DEGREES_PER_REVOLUTION,
            secondDegrees = seconds / SECONDS_PER_MINUTE * DEGREES_PER_REVOLUTION
        )
    }

}

private const val MILLISECONDS_PER_SECOND = 1000f
private const val SECONDS_PER_HOUR = 3600f
private const val SECONDS_PER_MINUTE = 60f
private const val DEGREES_PER_REVOLUTION = 360f
