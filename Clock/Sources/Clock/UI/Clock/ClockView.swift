import SwiftUI
import CoreUI

public struct ClockView: View {

    @State private var presenter: ClockPresenter

    public init(presenter: ClockPresenter) {
        self.presenter = presenter
    }

    public var body: some View {
        VStack(spacing: .large) {
            Header(model: presenter.headerModel, action: onHeaderAction)

            TimelineView(.animation(minimumInterval: Constants.tickInterval, paused: !presenter.isCountingDown)) { _ in
                Clocks(model: presenter.clocksModel, action: onClocksAction)
            }

            ControlBar(model: presenter.controlBarModel, action: onControlBarAction)
        }
        .padding(.large)
        .primaryBackground()
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .supportsLandscape()
        .presentFullScreen(if: presenter.showResetDialog) {
            ResetDialog(action: onResetDialogAction)
        }
        .presentFullScreen(if: presenter.showPauseDialog) {
            PauseDialog(model: presenter.pauseDialogModel, action: onPauseDialogAction)
        }
    }

}

private extension ClockView {

    func onHeaderAction(_ action: Header.Action) {
        switch action {
        case .back: presenter.navigateBack()
        }
    }

    func onClocksAction(_ action: Clocks.Action) {
        switch action {
        case let .press(side): presenter.press(side)
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
        case let .selectDisplayMode(mode): presenter.selectDisplayMode(mode)
        }
    }

}

private extension ClockView {

    enum Constants {

        static let tickInterval: TimeInterval = 1.0 / 60

    }

}
