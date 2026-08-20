import Foundation
import Core

nonisolated struct PresetRuleset: Identifiable, Equatable, Sendable {

    let id: String
    let category: LocalizedStringResource
    let description: LocalizedStringResource
    let timeControl: TimeControl

}

nonisolated extension PresetRuleset {

    static let bullet1plus0 = PresetRuleset(
        id: "bullet-1-0",
        category: .bulletCategory,
        description: .bullet1Plus0Description,
        timeControl: TimeControl(baseMinutes: 1, incrementSeconds: 0))

    static let blitz3plus2 = PresetRuleset(
        id: "blitz-3-2",
        category: .blitzCategory,
        description: .blitz3Plus2Description,
        timeControl: TimeControl(baseMinutes: 3, incrementSeconds: 2))

    static let blitz5plus0 = PresetRuleset(
        id: "blitz-5-0",
        category: .blitzCategory,
        description: .blitz5Plus0Description,
        timeControl: TimeControl(baseMinutes: 5, incrementSeconds: 0))

    static let rapid10plus0 = PresetRuleset(
        id: "rapid-10-0",
        category: .rapidCategory,
        description: .rapid10Plus0Description,
        timeControl: TimeControl(baseMinutes: 10, incrementSeconds: 0))

    static let rapid15plus10 = PresetRuleset(
        id: "rapid-15-10",
        category: .rapidCategory,
        description: .rapid15Plus10Description,
        timeControl: TimeControl(baseMinutes: 15, incrementSeconds: 10))

    static let classical90plus30 = PresetRuleset(
        id: "classical-90-30",
        category: .classicalCategory,
        description: .classical90Plus30Description,
        timeControl: TimeControl(baseMinutes: 90, incrementSeconds: 30))

    static let catalogue: [PresetRuleset] = [
        bullet1plus0,
        blitz3plus2,
        blitz5plus0,
        rapid10plus0,
        rapid15plus10,
        classical90plus30
    ]

}
