package com.zeitnot.android

internal object SharedLibrary {

    init {
        System.loadLibrary("Shared")
    }

    fun ensureLoaded() = Unit

}
