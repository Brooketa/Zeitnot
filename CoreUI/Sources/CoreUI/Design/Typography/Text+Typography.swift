import SwiftUI

public extension Text {

    func largeTitle(_ color: Color = ColorPalette.ink) -> Text {
        font(Typography.largeTitle).tracking(Tracking.largeTitle).foregroundStyle(color)
    }

    func title(_ color: Color = ColorPalette.ink) -> Text {
        font(Typography.title).tracking(Tracking.title).foregroundStyle(color)
    }

    func headline(_ color: Color = ColorPalette.ink) -> Text {
        font(Typography.headline).tracking(Tracking.headline).foregroundStyle(color)
    }

    func body(_ color: Color = ColorPalette.ink) -> Text {
        font(Typography.body).tracking(Tracking.body).foregroundStyle(color)
    }

    func calloutBold(_ color: Color = ColorPalette.ink) -> Text {
        font(Typography.calloutBold).tracking(Tracking.calloutBold).foregroundStyle(color)
    }

    func buttonLabel(_ color: Color = ColorPalette.inkInverse) -> Text {
        font(Typography.buttonLabel).tracking(Tracking.buttonLabel).foregroundStyle(color)
    }

    func callout(_ color: Color = ColorPalette.textSecondary) -> Text {
        font(Typography.callout).tracking(Tracking.callout).foregroundStyle(color)
    }

    func footnote(_ color: Color = ColorPalette.textSecondary) -> Text {
        font(Typography.footnote).tracking(Tracking.footnote).foregroundStyle(color)
    }

    func label(_ color: Color = ColorPalette.textTertiary) -> Text {
        font(Typography.label).tracking(Tracking.label).foregroundStyle(color)
    }

    func micro(_ color: Color = ColorPalette.accent) -> Text {
        font(Typography.micro).tracking(Tracking.micro).foregroundStyle(color)
    }

}
