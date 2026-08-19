import SwiftUI
import Setup

@main
struct ZeitnotApp: App {

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SetupView()
            }
            .preferredColorScheme(.light)
        }
    }

}
