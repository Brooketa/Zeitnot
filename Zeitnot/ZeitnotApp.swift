import SwiftUI
import Setup

@main
struct ZeitnotApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SetupView()
            }
            .preferredColorScheme(.light)
        }
    }

}
