import Testing
import Core
@testable import Clock

struct DialHandsTests {

    private static let tolerance = 0.000_001

    @Test(arguments: [
        (seconds: 5400.0, degrees: 540.0),
        (seconds: 900.0, degrees: 90.0),
        (seconds: 600.0, degrees: 60.0),
        (seconds: 300.0, degrees: 30.0),
        (seconds: 180.0, degrees: 18.0),
        (seconds: 60.0, degrees: 6.0)
    ])
    func placesTheMinuteHandForEveryPresetBaseTime(seconds: Double, degrees: Double) {
        let hands = DialHands(remaining: .seconds(seconds))

        #expect(abs(hands.minuteDegrees - degrees) < Self.tolerance)
    }

    @Test
    func putsBothHandsOnTwelveAtZero() {
        let hands = DialHands(remaining: .zero)

        #expect(hands.minuteDegrees == 0)
        #expect(hands.secondDegrees == 0)
    }

    @Test(arguments: [
        (seconds: 59.5, degrees: 357.0),
        (seconds: 30.0, degrees: 180.0),
        (seconds: 15.0, degrees: 90.0),
        (seconds: 0.25, degrees: 1.5)
    ])
    func sweepsTheSecondHandOnceAMinute(seconds: Double, degrees: Double) {
        let hands = DialHands(remaining: .seconds(seconds))

        #expect(abs(hands.secondDegrees - degrees) < Self.tolerance)
    }

    @Test
    func keepsTheAngleContinuousPastAFullRevolution() {
        #expect(abs(DialHands(remaining: .seconds(3600)).minuteDegrees - 360) < Self.tolerance)
        #expect(abs(DialHands(remaining: .seconds(5400)).minuteDegrees - 540) < Self.tolerance)
    }

    @Test
    func neverWrapsTheSecondHandAcrossAMinuteBoundary() {
        let justBefore = DialHands(remaining: .seconds(59.999)).secondDegrees
        let justAfter = DialHands(remaining: .seconds(60.001)).secondDegrees

        #expect(justAfter > justBefore)
        #expect(justAfter - justBefore < 1)
    }

    @Test
    func readsNinetyMinutesAndThirtyMinutesAlike() {
        let full = DialHands(remaining: .seconds(5400))
        let halfSpent = DialHands(remaining: .seconds(1800))

        #expect(full.minuteDegrees.truncatingRemainder(dividingBy: 360) == halfSpent.minuteDegrees)
    }

    @Test
    func keepsMovingBackWhenTimeIsBankedPastBaseTime() {
        let atBase = DialHands(remaining: .seconds(900))
        let banked = DialHands(remaining: .seconds(960))

        #expect(banked.minuteDegrees > atBase.minuteDegrees)
    }

    @Test
    func doesNotTruncateToWholeSecondsAsTheReadingDoes() {
        let remaining = Duration.seconds(1.9)
        let hands = DialHands(remaining: remaining)

        #expect(remaining.timeReading == "0:01")
        #expect(abs(hands.secondDegrees - 11.4) < Self.tolerance)
    }

    @Test(arguments: [-0.1, -5.0, -3600.0])
    func clampsNegativeDurationsToZero(seconds: Double) {
        let hands = DialHands(remaining: .seconds(seconds))

        #expect(hands.minuteDegrees == 0)
        #expect(hands.secondDegrees == 0)
    }

}
