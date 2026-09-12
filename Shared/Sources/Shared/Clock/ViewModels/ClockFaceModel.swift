public struct ClockFaceModel {

    public let side: ClockFaceSide
    public let state: ClockFaceState
    public let timeDisplay: ClockFaceTimeDisplay

}

public enum ClockFaceTimeDisplay: Equatable {

    case digital(DigitalFaceModel)
    case analog(AnalogFaceModel)

}
