import Foundation
import Testing
import Core

struct TimeControlTests {

    @Test
    func carriesBaseAndIncrement() {
        let timeControl = TimeControl(baseMinutes: 90, incrementSeconds: 30)

        #expect(timeControl.baseMinutes == 90)
        #expect(timeControl.incrementSeconds == 30)
    }

    @Test
    func zeroIncrementIsSupported() {
        let timeControl = TimeControl(baseMinutes: 1, incrementSeconds: 0)

        #expect(timeControl.incrementSeconds == 0)
    }

    @Test
    func equalValuesAreEqual() {
        #expect(TimeControl(baseMinutes: 3, incrementSeconds: 2) == TimeControl(baseMinutes: 3, incrementSeconds: 2))
    }

    @Test
    func differingValuesAreNotEqual() {
        #expect(TimeControl(baseMinutes: 3, incrementSeconds: 2) != TimeControl(baseMinutes: 3, incrementSeconds: 0))
    }

    @Test(arguments: [
        (baseMinutes: 1, incrementSeconds: 0),
        (baseMinutes: 3, incrementSeconds: 2),
        (baseMinutes: 5, incrementSeconds: 0),
        (baseMinutes: 10, incrementSeconds: 0),
        (baseMinutes: 15, incrementSeconds: 10),
        (baseMinutes: 90, incrementSeconds: 30)
    ])
    func survivesEncodingRoundTrip(baseMinutes: Int, incrementSeconds: Int) throws {
        let timeControl = TimeControl(baseMinutes: baseMinutes, incrementSeconds: incrementSeconds)

        let encoded = try JSONEncoder().encode(timeControl)
        let decoded = try JSONDecoder().decode(TimeControl.self, from: encoded)

        #expect(decoded == timeControl)
    }

    @Test
    func encodesAsPlainNumbers() throws {
        let encoded = try JSONEncoder().encode(TimeControl(baseMinutes: 3, incrementSeconds: 2))

        let json = try #require(String(data: encoded, encoding: .utf8))

        #expect(json.contains("\"baseMinutes\":3"))
        #expect(json.contains("\"incrementSeconds\":2"))
    }

    @Test
    func theBaseTimeIsTheBaseMinutesAsADuration() {
        #expect(TimeControl(baseMinutes: 90, incrementSeconds: 30).baseTime == .seconds(5_400))
        #expect(TimeControl(baseMinutes: 1, incrementSeconds: 0).baseTime == .seconds(60))
    }

    @Test
    func theIncrementIsTheIncrementSecondsAsADuration() {
        #expect(TimeControl(baseMinutes: 3, incrementSeconds: 2).increment == .seconds(2))
        #expect(TimeControl(baseMinutes: 5, incrementSeconds: 0).increment == .zero)
    }

}
