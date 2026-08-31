import Foundation
import Testing
@testable import Setup

struct PresetRulesetCopyTests {

    @Test(arguments: [
        (preset: PresetRuleset.bullet1plus0, description: "One minute each. Sudden death."),
        (preset: PresetRuleset.blitz3plus2, description: "Three minutes, plus 2s per move."),
        (preset: PresetRuleset.blitz5plus0, description: "Five minutes each, classic blitz game."),
        (preset: PresetRuleset.rapid10plus0, description: "Ten minutes each, no increment."),
        (preset: PresetRuleset.rapid15plus10, description: "Fifteen minutes, plus 10s per move."),
        (preset: PresetRuleset.classical90plus30, description: "90 minutes each, plus 30s per move.")
    ])
    func everyPresetHasItsDescription(preset: PresetRuleset, description: String) {
        #expect(String(localized: preset.description) == description)
    }

}
