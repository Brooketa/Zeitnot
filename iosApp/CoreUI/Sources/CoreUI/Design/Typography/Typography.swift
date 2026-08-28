import SwiftUI

public enum Typography {

    public static let clockDigits = Style(
        size: 76,
        weight: .bold,
        tracking: -2.3,
        isMonospacedDigit: true,
        color: ColorPalette.ink)

    public static let largeTitle = Style(size: 32, weight: .bold, tracking: -0.8, color: ColorPalette.ink)
    public static let title = Style(size: 22, weight: .heavy, tracking: -0.6, color: ColorPalette.ink)
    public static let headline = Style(size: 19, weight: .bold, color: ColorPalette.ink)
    public static let body = Style(size: 17, weight: .semibold, color: ColorPalette.ink)
    public static let calloutBold = Style(size: 15, weight: .semibold, color: ColorPalette.ink)
    public static let buttonLabel = Style(size: 15, weight: .semibold, tracking: 0.6, color: ColorPalette.inkInverse)
    public static let callout = Style(size: 15, weight: .regular, color: ColorPalette.textSecondary)
    public static let footnote = Style(size: 13, weight: .regular, color: ColorPalette.textSecondary)
    public static let label = Style(size: 12, weight: .semibold, tracking: 1.4, color: ColorPalette.textTertiary)
    public static let playerName = Style(size: 12, weight: .bold, tracking: 2.4, color: ColorPalette.textSecondary)
    public static let micro = Style(size: 10, weight: .semibold, tracking: 1.8, color: ColorPalette.accent)

}

public extension Typography {

    struct Style {

        public let font: Font
        public let tracking: CGFloat
        public let color: Color

        init(
            size: CGFloat,
            weight: Font.Weight,
            tracking: CGFloat = 0,
            isMonospacedDigit: Bool = false,
            color: Color
        ) {
            let font = Font.system(size: size, weight: weight)

            self.font = isMonospacedDigit ? font.monospacedDigit() : font
            self.tracking = tracking
            self.color = color
        }

    }

}
