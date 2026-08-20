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

            ControlBar(action: presenter.handle)
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
            ClockFace(model: presenter.whiteClock)

            ClockFace(model: presenter.blackClock)
        }
    }

    var moveNumber: some View {
        Text(presenter.moveNumber)
            .label(ColorPalette.textSecondary)
            .textCase(.uppercase)
    }

}
