import Foundation

public extension CGFloat {

    static let extraSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let extraLarge: CGFloat = 20
    static let jumbo: CGFloat = 24

    static func grid(_ multiplier: CGFloat) -> CGFloat {
        extraSmall * multiplier
    }

}
