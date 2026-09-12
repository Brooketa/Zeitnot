package com.zeitnot.android

import java.util.concurrent.atomic.AtomicBoolean

enum class RulesetCategory {
    BULLET,
    BLITZ,
    RAPID,
    CLASSICAL
}

data class GameConfiguration(
    val baseMinutes: Int,
    val incrementSeconds: Int,
    val category: RulesetCategory
)

data class Ruleset(
    val id: String,
    val category: RulesetCategory,
    val baseMinutes: Int,
    val incrementSeconds: Int,
    val isSelected: Boolean
)

class SetupPresenterNative : AutoCloseable {

    init {
        SharedLibrary.ensureLoaded()
    }

    private val handle: Long = nativeCreate()
    private val closed = AtomicBoolean(false)

    val rulesets: List<Ruleset>
        get() {
            check(!closed.get()) { "SetupPresenterNative already closed" }

            return (0 until nativeRulesetCount(handle)).map { index ->
                Ruleset(
                    id = nativeRulesetId(handle, index),
                    category = RulesetCategory.entries[nativeRulesetCategory(handle, index)],
                    baseMinutes = nativeRulesetBaseMinutes(handle, index),
                    incrementSeconds = nativeRulesetIncrementSeconds(handle, index),
                    isSelected = nativeRulesetIsSelected(handle, index)
                )
            }
        }

    val requestedGame: GameConfiguration?
        get() {
            check(!closed.get()) { "SetupPresenterNative already closed" }

            if (!nativeDidRequestClock(handle)) return null

            return GameConfiguration(
                baseMinutes = nativeRequestedBaseMinutes(handle),
                incrementSeconds = nativeRequestedIncrementSeconds(handle),
                category = RulesetCategory.entries[nativeRequestedCategory(handle)]
            )
        }

    fun select(id: String) {
        check(!closed.get()) { "SetupPresenterNative already closed" }

        nativeSelectRuleset(handle, id)
    }

    fun startGame() {
        check(!closed.get()) { "SetupPresenterNative already closed" }

        nativeStartGame(handle)
    }

    override fun close() {
        if (closed.compareAndSet(false, true)) {
            nativeDestroy(handle)
        }
    }

    private external fun nativeCreate(): Long
    private external fun nativeDestroy(handle: Long)
    private external fun nativeRulesetCount(handle: Long): Int
    private external fun nativeRulesetId(handle: Long, index: Int): String
    private external fun nativeRulesetCategory(handle: Long, index: Int): Int
    private external fun nativeRulesetBaseMinutes(handle: Long, index: Int): Int
    private external fun nativeRulesetIncrementSeconds(handle: Long, index: Int): Int
    private external fun nativeRulesetIsSelected(handle: Long, index: Int): Boolean
    private external fun nativeSelectRuleset(handle: Long, id: String)
    private external fun nativeStartGame(handle: Long)
    private external fun nativeDidRequestClock(handle: Long): Boolean
    private external fun nativeRequestedBaseMinutes(handle: Long): Int
    private external fun nativeRequestedIncrementSeconds(handle: Long): Int
    private external fun nativeRequestedCategory(handle: Long): Int

}
