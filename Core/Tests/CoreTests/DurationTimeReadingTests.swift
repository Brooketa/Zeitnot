import Testing
import Core

struct DurationTimeReadingTests {

    @Test(arguments: [
        (seconds: 0.0, reading: "0:00"),
        (seconds: 0.9, reading: "0:00"),
        (seconds: 1.9, reading: "0:01"),
        (seconds: 8.4, reading: "0:08"),
        (seconds: 59.0, reading: "0:59"),
        (seconds: 59.9, reading: "0:59")
    ])
    func readsBelowAMinuteAsMinutesAndSeconds(seconds: Double, reading: String) {
        #expect(Duration.seconds(seconds).timeReading == reading)
    }

    @Test(arguments: [
        (seconds: 60.0, reading: "1:00"),
        (seconds: 187.0, reading: "3:07"),
        (seconds: 599.0, reading: "9:59"),
        (seconds: 600.0, reading: "10:00"),
        (seconds: 3599.0, reading: "59:59"),
        (seconds: 3599.9, reading: "59:59")
    ])
    func readsBelowAnHourAsMinutesAndSeconds(seconds: Double, reading: String) {
        #expect(Duration.seconds(seconds).timeReading == reading)
    }

    @Test(arguments: [
        (seconds: 3600.0, reading: "1:00:00"),
        (seconds: 3661.0, reading: "1:01:01"),
        (seconds: 5400.0, reading: "1:30:00"),
        (seconds: 36000.0, reading: "10:00:00")
    ])
    func readsAnHourOrMoreAsHoursMinutesAndSeconds(seconds: Double, reading: String) {
        #expect(Duration.seconds(seconds).timeReading == reading)
    }

    @Test
    func switchesFormatAtTheMinuteBoundary() {
        #expect(Duration.seconds(59.9).timeReading == "0:59")
        #expect(Duration.seconds(60).timeReading == "1:00")
    }

    @Test
    func switchesFormatAtTheHourBoundary() {
        #expect(Duration.seconds(3599.9).timeReading == "59:59")
        #expect(Duration.seconds(3600).timeReading == "1:00:00")
    }

    @Test(arguments: [-0.1, -5.0, -3600.0])
    func clampsNegativeDurationsToZero(seconds: Double) {
        #expect(Duration.seconds(seconds).timeReading == "0:00")
    }

    @Test(arguments: [
        (seconds: 1.999, reading: "0:01"),
        (seconds: 59.999, reading: "0:59"),
        (seconds: 3599.999, reading: "59:59")
    ])
    func truncatesTowardsZeroRatherThanRounding(seconds: Double, reading: String) {
        #expect(Duration.seconds(seconds).timeReading == reading)
    }

    @Test(arguments: [
        (baseMinutes: 1, reading: "1:00"),
        (baseMinutes: 3, reading: "3:00"),
        (baseMinutes: 15, reading: "15:00"),
        (baseMinutes: 90, reading: "1:30:00")
    ])
    func readsEveryPresetBaseTime(baseMinutes: Int, reading: String) {
        #expect(Duration.seconds(baseMinutes * 60).timeReading == reading)
    }

}
