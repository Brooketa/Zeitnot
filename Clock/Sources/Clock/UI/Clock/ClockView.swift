import SwiftUI
import CoreUI

public struct ClockView: View {

    @State private var presenter: ClockPresenter

    public init(presenter: ClockPresenter) {
        self.presenter = presenter
    }

    public var body: some View {
        VStack(spacing: .lg) {
            clocks

            ControlBar(action: onControlBarAction)
        }
        .padding(.lg)
        .primaryBackground()
        .navigationTitle(presenter.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                moveNumber
            }
        }
        .supportsLandscape()
        .task {
            await presenter.startTicking()
        }
    }

    var clocks: some View {
        HStack(spacing: .lg) {
            ClockFace(model: presenter.whiteClock, action: onClockFaceAction)

            ClockFace(model: presenter.blackClock, action: onClockFaceAction)
        }
    }

    var moveNumber: some View {
        Text(presenter.moveNumber)
            .label(ColorPalette.textSecondary)
            .textCase(.uppercase)
    }

}

private extension ClockView {

    func onClockFaceAction(_ action: ClockFace.Action) {
        switch action {
        case let .press(player): presenter.press(player)
        }
    }

    func onControlBarAction(_ action: ControlBar.Action) {
        switch action {
        case .pause: presenter.pause()
        case .reset: presenter.reset()
        }
    }

}
