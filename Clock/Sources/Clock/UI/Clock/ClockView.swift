import SwiftUI
import CoreUI

public struct ClockView: View {

    @State private var presenter: ClockPresenter

    public init(presenter: ClockPresenter) {
        self.presenter = presenter
    }

    public var body: some View {
        VStack(spacing: .lg) {
            Header(model: presenter.headerModel, action: onHeaderAction)

            clocks

            ControlBar(model: presenter.controlBarModel, action: onControlBarAction)
        }
		.presentFullScreen(if: presenter.showResetDialog) {
			ResetDialog(action: onResetDialogAction)
		}
		.presentFullScreen(if: presenter.showPauseDialog) {
			PauseDialog(model: presenter.pauseDialogModel, action: onPauseDialogAction)
		}
        .padding(.lg)
        .primaryBackground()
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .supportsLandscape()
    }

    var clocks: some View {
        TimelineView(.animation(minimumInterval: Constants.tickInterval, paused: presenter.isPaused)) { _ in
            HStack(spacing: .lg) {
                ClockFace(model: presenter.whiteClock, action: onClockFaceAction)

                ClockFace(model: presenter.blackClock, action: onClockFaceAction)
            }
        }
    }

}

private extension ClockView {

    func onHeaderAction(_ action: Header.Action) {
        switch action {
        case .back: presenter.navigateBack()
        }
    }

    func onClockFaceAction(_ action: ClockFace.Action) {
        switch action {
        case let .press(player): presenter.press(player)
        }
    }

    func onPauseDialogAction(_ action: PauseDialog.Action) {
        switch action {
        case .resume: presenter.resume()
        }
    }

    func onResetDialogAction(_ action: ResetDialog.Action) {
        switch action {
        case .confirm: presenter.confirmReset()
        case .cancel: presenter.cancelReset()
        }
    }

    func onControlBarAction(_ action: ControlBar.Action) {
        switch action {
        case .pause: presenter.pause()
        case .reset: presenter.reset()
        }
    }

}

private extension ClockView {

    enum Constants {

        static let tickInterval: TimeInterval = 0.1

    }

}
