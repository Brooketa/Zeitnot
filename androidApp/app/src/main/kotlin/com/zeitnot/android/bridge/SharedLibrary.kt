package com.zeitnot.android.bridge

internal object SharedLibrary {

    init {
        System.loadLibrary("Shared")
    }

    fun ensureLoaded() = Unit

}
