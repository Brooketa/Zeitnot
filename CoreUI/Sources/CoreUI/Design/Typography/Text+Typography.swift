import SwiftUI

public extension Text {

    func largeTitle(_ color: Color? = nil) -> Text {
        styled(Typography.largeTitle, color)
    }

    func title(_ color: Color? = nil) -> Text {
        styled(Typography.title, color)
    }

    func headline(_ color: Color? = nil) -> Text {
        styled(Typography.headline, color)
    }

    func body(_ color: Color? = nil) -> Text {
        styled(Typography.body, color)
    }

    func calloutBold(_ color: Color? = nil) -> Text {
        styled(Typography.calloutBold, color)
    }

    func buttonLabel(_ color: Color? = nil) -> Text {
        styled(Typography.buttonLabel, color)
    }

    func callout(_ color: Color? = nil) -> Text {
        styled(Typography.callout, color)
    }

    func footnote(_ color: Color? = nil) -> Text {
        styled(Typography.footnote, color)
    }

    func label(_ color: Color? = nil) -> Text {
        styled(Typography.label, color)
    }

    func micro(_ color: Color? = nil) -> Text {
        styled(Typography.micro, color)
    }

    private func styled(_ style: Typography.Style, _ color: Color?) -> Text {
        font(style.font).tracking(style.tracking).foregroundStyle(color ?? style.color)
    }

}
