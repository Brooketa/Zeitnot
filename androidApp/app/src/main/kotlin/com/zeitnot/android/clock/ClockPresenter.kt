package com.zeitnot.android.clock

import com.zeitnot.android.domain.ClockStatus
import com.zeitnot.android.domain.GameServiceContract
import com.zeitnot.android.domain.Player
import com.zeitnot.android.domain.RulesetCategory
import com.zeitnot.android.setup.GameConfiguration

enum class DisplayMode {
    DIGITAL,
    ANALOG
}

data class DialHands(val minuteDegrees: Float, val secondDegrees: Float)

data class ClockFaceModel(
    val side: Player,
    val status: ClockStatus,
    val reading: String,
    val hands: DialHands
)

data class HeaderModel(
    val category: RulesetCategory,
    val baseMinutes: Int,
    val incrementSeconds: Int,
    val moveNumber: Int,
    val isRunning: Boolean
)

data class ControlBarModel(
    val canPause: Boolean,
    val canReset: Boolean
)

data class ClockModel(
    val header: HeaderModel,
    val white: ClockFaceModel,
    val black: ClockFaceModel,
    val controlBar: ControlBarModel,
    val displayMode: DisplayMode,
    val playerToMove: Player,
    val isRunning: Boolean,
    val showPauseDialog: Boolean,
    val showResetDialog: Boolean
)

class ClockPresenter(
    private val configuration: GameConfiguration,
    private val game: GameServiceContract
) : AutoCloseable {

    private var displayMode = DisplayMode.DIGITAL
    private var showResetDialog = false

    fun model(): ClockModel {
        val snapshot = game.snapshot()

        return ClockModel(
            header = HeaderModel(
                category = configuration.category,
                baseMinutes = configuration.baseMinutes,
                incrementSeconds = configuration.incrementSeconds,
                moveNumber = snapshot.moveNumber,
                isRunning = snapshot.isRunning
            ),
            white = faceModel(Player.WHITE),
            black = faceModel(Player.BLACK),
            controlBar = ControlBarModel(
                canPause = snapshot.isRunning,
                canReset = snapshot.isRunning || snapshot.isFinished
            ),
            displayMode = displayMode,
            playerToMove = snapshot.playerToMove,
            isRunning = snapshot.isRunning,
            showPauseDialog = snapshot.isPaused,
            showResetDialog = showResetDialog
        )
    }

    fun press(side: Player) = game.press(side)

    fun pause() = game.pause()

    fun resume() = game.resume()

    fun select(displayMode: DisplayMode) {
        this.displayMode = displayMode
    }

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
            status = clock.status,
            reading = game.reading(player),
            hands = hands(clock.remainingMillis)
        )
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
