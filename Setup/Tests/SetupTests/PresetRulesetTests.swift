import Core
import Testing
@testable import Setup

struct PresetRulesetTests {

    @Test
    func catalogueIsInDisplayOrder() {
        #expect(PresetRuleset.allCases == [
            .bullet1plus0,
            .blitz3plus2,
            .blitz5plus0,
            .rapid10plus0,
            .rapid15plus10,
            .classical90plus30
        ])
    }

    @Test(arguments: [
        (preset: PresetRuleset.bullet1plus0, category: "Bullet"),
        (preset: PresetRuleset.blitz3plus2, category: "Blitz"),
        (preset: PresetRuleset.blitz5plus0, category: "Blitz"),
        (preset: PresetRuleset.rapid10plus0, category: "Rapid"),
        (preset: PresetRuleset.rapid15plus10, category: "Rapid"),
        (preset: PresetRuleset.classical90plus30, category: "Classical")
    ])
    func everyPresetHasItsCategory(preset: PresetRuleset, category: String) {
        #expect(preset.category == category)
    }

    @Test(arguments: [
        (preset: PresetRuleset.bullet1plus0, baseMinutes: 1, incrementSeconds: 0),
        (preset: PresetRuleset.blitz3plus2, baseMinutes: 3, incrementSeconds: 2),
        (preset: PresetRuleset.blitz5plus0, baseMinutes: 5, incrementSeconds: 0),
        (preset: PresetRuleset.rapid10plus0, baseMinutes: 10, incrementSeconds: 0),
        (preset: PresetRuleset.rapid15plus10, baseMinutes: 15, incrementSeconds: 10),
        (preset: PresetRuleset.classical90plus30, baseMinutes: 90, incrementSeconds: 30)
    ])
    func everyPresetHasItsTimeControl(preset: PresetRuleset, baseMinutes: Int, incrementSeconds: Int) {
        #expect(preset.timeControl == TimeControl(baseMinutes: baseMinutes, incrementSeconds: incrementSeconds))
    }

    @Test(arguments: [
        (preset: PresetRuleset.bullet1plus0, description: "One minute each. Sudden death."),
        (preset: PresetRuleset.blitz3plus2, description: "Three minutes, plus 2s on every completed move."),
        (preset: PresetRuleset.blitz5plus0, description: "Five minutes each — the classic blitz game."),
        (preset: PresetRuleset.rapid10plus0, description: "Ten minutes each, no increment."),
        (preset: PresetRuleset.rapid15plus10, description: "Fifteen minutes, plus 10s per move."),
        (preset: PresetRuleset.classical90plus30, description: "90 minutes each, plus 30s per move.")
    ])
    func everyPresetHasItsDescription(preset: PresetRuleset, description: String) {
        #expect(preset.description == description)
    }

    @Test(arguments: [
        (preset: PresetRuleset.bullet1plus0, storageKey: "bullet-1-0"),
        (preset: PresetRuleset.blitz3plus2, storageKey: "blitz-3-2"),
        (preset: PresetRuleset.blitz5plus0, storageKey: "blitz-5-0"),
        (preset: PresetRuleset.rapid10plus0, storageKey: "rapid-10-0"),
        (preset: PresetRuleset.rapid15plus10, storageKey: "rapid-15-10"),
        (preset: PresetRuleset.classical90plus30, storageKey: "classical-90-30")
    ])
    func everyPresetHasAStableStorageKey(preset: PresetRuleset, storageKey: String) {
        #expect(preset.rawValue == storageKey)
    }

}
