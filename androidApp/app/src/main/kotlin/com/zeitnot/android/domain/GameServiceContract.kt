package com.zeitnot.android.domain

import java.util.concurrent.atomic.AtomicBoolean

enum class Player {
    WHITE,
    BLACK
}

enum class ClockStatus {
    AWAITING_START,
    TO_MOVE,
    LOW_TIME,
    WAITING,
    FLAGGED
}

data class ClockSnapshot(
    val remainingMillis: Long,
    val moveCount: Int,
    val status: ClockStatus
)

data class GameSnapshot(
    val white: ClockSnapshot,
    val black: ClockSnapshot,
    val playerToMove: Player,
    val moveNumber: Int,
    val winner: Player?,
    val isAwaitingStart: Boolean,
    val isRunning: Boolean,
    val isPaused: Boolean,
    val isFinished: Boolean
) {

    val isInProgress: Boolean
        get() = isRunning || isPaused

    operator fun get(player: Player) = if (player == Player.WHITE) white else black

}

interface GameServiceContract : AutoCloseable {

    fun snapshot(): GameSnapshot

    fun reading(player: Player): String

    fun press(player: Player)

    fun pause()

    fun resume()

    fun reset()

}
