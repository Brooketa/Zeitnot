package com.zeitnot.android

import java.util.concurrent.atomic.AtomicBoolean

enum class ClockSide {
    WHITE,
    BLACK
}

enum class ClockFaceState {
    AWAITING_START,
    TO_MOVE,
    LOW_TIME,
    WAITING,
    FLAGGED
}

data class ClockFace(
    val state: ClockFaceState,
    val reading: String?,
    val minuteDegrees: Double,
    val secondDegrees: Double
)

data class ClockSnapshot(
    val moveNumber: Int,
    val isRunning: Boolean,
    val white: ClockFace,
    val black: ClockFace,
    val canPause: Boolean,
    val canReset: Boolean,
    val showPauseDialog: Boolean,
    val showResetDialog: Boolean,
    val didRequestBack: Boolean
)

class ClockPresenterNative(configuration: GameConfiguration) : AutoCloseable {

    init {
        SharedLibrary.ensureLoaded()
    }

    private val handle: Long = nativeCreate(
        configuration.baseMinutes,
        configuration.incrementSeconds,
        configuration.category.ordinal
    )
    private val closed = AtomicBoolean(false)

    fun snapshot(): ClockSnapshot {
        check(!closed.get()) { "ClockPresenterNative already closed" }

        return ClockSnapshot(
            moveNumber = nativeMoveNumber(handle),
            isRunning = nativeIsRunning(handle),
            white = face(ClockSide.WHITE),
            black = face(ClockSide.BLACK),
            canPause = nativeCanPause(handle),
            canReset = nativeCanReset(handle),
            showPauseDialog = nativeShowPauseDialog(handle),
            showResetDialog = nativeShowResetDialog(handle),
            didRequestBack = nativeDidRequestBack(handle)
        )
    }

    fun press(side: ClockSide) = nativePress(handle, side.ordinal)

    fun pause() = nativePause(handle)

    fun resume() = nativeResume(handle)

    fun reset() = nativeReset(handle)

    fun confirmReset() = nativeConfirmReset(handle)

    fun cancelReset() = nativeCancelReset(handle)

    fun navigateBack() = nativeNavigateBack(handle)

    override fun close() {
        if (closed.compareAndSet(false, true)) {
            nativeDestroy(handle)
        }
    }

    private fun face(side: ClockSide) = ClockFace(
        state = ClockFaceState.entries[nativeFaceState(handle, side.ordinal)],
        reading = nativeReading(handle, side.ordinal),
        minuteDegrees = nativeMinuteDegrees(handle, side.ordinal),
        secondDegrees = nativeSecondDegrees(handle, side.ordinal)
    )

    private external fun nativeCreate(baseMinutes: Int, incrementSeconds: Int, category: Int): Long
    private external fun nativeDestroy(handle: Long)
    private external fun nativeMoveNumber(handle: Long): Int
    private external fun nativeIsRunning(handle: Long): Boolean
    private external fun nativeFaceState(handle: Long, side: Int): Int
    private external fun nativeReading(handle: Long, side: Int): String?
    private external fun nativeMinuteDegrees(handle: Long, side: Int): Double
    private external fun nativeSecondDegrees(handle: Long, side: Int): Double
    private external fun nativeCanPause(handle: Long): Boolean
    private external fun nativeCanReset(handle: Long): Boolean
    private external fun nativeShowPauseDialog(handle: Long): Boolean
    private external fun nativeShowResetDialog(handle: Long): Boolean
    private external fun nativePauseDialogPlayer(handle: Long): Int
    private external fun nativeDisplayMode(handle: Long): Int
    private external fun nativeSetDisplayMode(handle: Long, mode: Int)
    private external fun nativePress(handle: Long, side: Int)
    private external fun nativePause(handle: Long)
    private external fun nativeResume(handle: Long)
    private external fun nativeReset(handle: Long)
    private external fun nativeConfirmReset(handle: Long)
    private external fun nativeCancelReset(handle: Long)
    private external fun nativeNavigateBack(handle: Long)
    private external fun nativeDidRequestBack(handle: Long): Boolean

}
