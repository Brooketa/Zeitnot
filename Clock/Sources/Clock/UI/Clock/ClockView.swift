import SwiftUI
import CoreUI

public struct ClockView: View {

    private let presenter: ClockPresenter

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
