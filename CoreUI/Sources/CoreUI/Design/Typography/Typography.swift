import SwiftUI

public enum Typography {

    public static let largeTitle = Font.system(size: 32, weight: .bold)
    public static let title = Font.system(size: 22, weight: .heavy)
    public static let headline = Font.system(size: 19, weight: .bold)
    public static let body = Font.system(size: 17, weight: .semibold)
    public static let calloutBold = Font.system(size: 15, weight: .semibold)
    public static let buttonLabel = Font.system(size: 15, weight: .semibold)
    public static let callout = Font.system(size: 15, weight: .regular)
    public static let footnote = Font.system(size: 13, weight: .regular)
    public static let label = Font.system(size: 12, weight: .semibold)
    public static let micro = Font.system(size: 10, weight: .semibold)

}

public enum Tracking {

    public static let largeTitle: CGFloat = -0.8
    public static let title: CGFloat = -0.6
    public static let headline: CGFloat = 0
    public static let body: CGFloat = 0
    public static let calloutBold: CGFloat = 0
    public static let buttonLabel: CGFloat = 0.6
    public static let callout: CGFloat = 0
    public static let footnote: CGFloat = 0
    public static let label: CGFloat = 1.4
    public static let micro: CGFloat = 1.8

}
