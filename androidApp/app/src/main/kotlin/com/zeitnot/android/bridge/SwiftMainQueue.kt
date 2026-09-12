package com.zeitnot.android.bridge

import android.view.Choreographer

object SwiftMainQueue {

    init {
        SharedLibrary.ensureLoaded()
    }

    private var isPumping = false

    private val frameCallback = Choreographer.FrameCallback {
        nativeDrain()

        if (isPumping) {
            Choreographer.getInstance().postFrameCallback(callback)
        }
    }

    private val callback: Choreographer.FrameCallback
        get() = frameCallback

    fun start() {
        if (isPumping) return

        isPumping = true
        Choreographer.getInstance().postFrameCallback(frameCallback)
    }

    fun stop() {
        isPumping = false
    }

    private external fun nativeDrain()

}
