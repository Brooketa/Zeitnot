import SwiftUI

public extension Text {

    func largeTitle(_ color: Color = Typography.largeTitle.color) -> Text {
        styled(Typography.largeTitle, color)
    }

    func title(_ color: Color = Typography.title.color) -> Text {
        styled(Typography.title, color)
    }

    func headline(_ color: Color = Typography.headline.color) -> Text {
        styled(Typography.headline, color)
    }

    func body(_ color: Color = Typography.body.color) -> Text {
        styled(Typography.body, color)
    }

    func calloutBold(_ color: Color = Typography.calloutBold.color) -> Text {
        styled(Typography.calloutBold, color)
    }

    func buttonLabel(_ color: Color = Typography.buttonLabel.color) -> Text {
        styled(Typography.buttonLabel, color)
    }

    func callout(_ color: Color = Typography.callout.color) -> Text {
        styled(Typography.callout, color)
    }

    func footnote(_ color: Color = Typography.footnote.color) -> Text {
        styled(Typography.footnote, color)
    }

    func label(_ color: Color = Typography.label.color) -> Text {
        styled(Typography.label, color)
    }

    func micro(_ color: Color = Typography.micro.color) -> Text {
        styled(Typography.micro, color)
    }

    private func styled(_ style: Typography.Style, _ color: Color) -> Text {
        font(style.font).tracking(style.tracking).foregroundStyle(color)
    }

}
