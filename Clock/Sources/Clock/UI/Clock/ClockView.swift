import SwiftUI
import CoreUI

public struct ClockView: View {

    @State private var presenter: ClockPresenter

    public init(presenter: ClockPresenter) {
        self.presenter = presenter
    }

    public var body: some View {
        Color.clear
            .primaryBackground()
            .navigationTitle(presenter.title)
            .navigationBarTitleDisplayMode(.inline)
            .supportsLandscape()
    }

}
