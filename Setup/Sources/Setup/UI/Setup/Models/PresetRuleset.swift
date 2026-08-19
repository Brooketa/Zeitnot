import Core

enum PresetRuleset: String, CaseIterable, Sendable {

    case bullet1plus0 = "bullet-1-0"
    case blitz3plus2 = "blitz-3-2"
    case blitz5plus0 = "blitz-5-0"
    case rapid10plus0 = "rapid-10-0"
    case rapid15plus10 = "rapid-15-10"
    case classical90plus30 = "classical-90-30"

    var category: String {
        switch self {
        case .bullet1plus0: "Bullet"
        case .blitz3plus2, .blitz5plus0: "Blitz"
        case .rapid10plus0, .rapid15plus10: "Rapid"
        case .classical90plus30: "Classical"
        }
    }

    var timeControl: TimeControl {
        switch self {
        case .bullet1plus0: TimeControl(baseMinutes: 1, incrementSeconds: 0)
        case .blitz3plus2: TimeControl(baseMinutes: 3, incrementSeconds: 2)
        case .blitz5plus0: TimeControl(baseMinutes: 5, incrementSeconds: 0)
        case .rapid10plus0: TimeControl(baseMinutes: 10, incrementSeconds: 0)
        case .rapid15plus10: TimeControl(baseMinutes: 15, incrementSeconds: 10)
        case .classical90plus30: TimeControl(baseMinutes: 90, incrementSeconds: 30)
        }
    }

    var description: String {
        switch self {
        case .bullet1plus0: "One minute each. Sudden death."
        case .blitz3plus2: "Three minutes, plus 2s on every completed move."
        case .blitz5plus0: "Five minutes each — the classic blitz game."
        case .rapid10plus0: "Ten minutes each, no increment."
        case .rapid15plus10: "Fifteen minutes, plus 10s per move."
        case .classical90plus30: "90 minutes each, plus 30s per move."
        }
    }

}
