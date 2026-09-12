package com.zeitnot.android.bridge

import com.zeitnot.android.domain.ClockSnapshot
import com.zeitnot.android.domain.ClockStatus
import com.zeitnot.android.domain.GameServiceContract
import com.zeitnot.android.domain.GameSnapshot
import com.zeitnot.android.domain.Player
import java.util.concurrent.atomic.AtomicBoolean

class GameService(baseMinutes: Int, incrementSeconds: Int) : GameServiceContract {

    init {
        SharedLibrary.ensureLoaded()
    }

    private val handle: Long = nativeCreate(baseMinutes, incrementSeconds)
    private val closed = AtomicBoolean(false)

    override fun snapshot(): GameSnapshot {
        check(!closed.get()) { "GameService already closed" }

        val values = nativeSnapshot(handle)

        return GameSnapshot(
            white = ClockSnapshot(values[0], values[1].toInt(), ClockStatus.entries[values[2].toInt()]),
            black = ClockSnapshot(values[3], values[4].toInt(), ClockStatus.entries[values[5].toInt()]),
            playerToMove = Player.entries[values[6].toInt()],
            moveNumber = values[7].toInt(),
            winner = values[8].toInt().takeIf { it >= 0 }?.let { Player.entries[it] },
            isAwaitingStart = values[9] == 1L,
            isRunning = values[10] == 1L,
            isPaused = values[11] == 1L,
            isFinished = values[12] == 1L
        )
    }

    override fun reading(player: Player): String = nativeReading(handle, player.ordinal)

    override fun press(player: Player) = nativePress(handle, player.ordinal)

    override fun pause() = nativePause(handle)

    override fun resume() = nativeResume(handle)

    override fun reset() = nativeReset(handle)

    override fun close() {
        if (closed.compareAndSet(false, true)) {
            nativeDestroy(handle)
        }
    }

    private external fun nativeCreate(baseMinutes: Int, incrementSeconds: Int): Long
    private external fun nativeDestroy(handle: Long)
    private external fun nativeSnapshot(handle: Long): LongArray
    private external fun nativeReading(handle: Long, player: Int): String
    private external fun nativePress(handle: Long, player: Int)
    private external fun nativePause(handle: Long)
    private external fun nativeResume(handle: Long)
    private external fun nativeReset(handle: Long)

}
