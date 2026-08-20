import SwiftUI
import Clock
import Setup

@main
struct ZeitnotApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var dependencies = Dependencies()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dependencies: dependencies)
                .environment(dependencies.router)
                .preferredColorScheme(.light)
        }
    }

    private struct ContentView: View {

        @Environment(\.dependencies) private var dependencies
        @Environment(AppRouter.self) private var router

        var body: some View {
            @Bindable var router = router

            NavigationStack(path: $router.navigationPath) {
                SetupView(presenter: dependencies.makeSetupPresenter())
                    .onDisappear { router.navigationDidComplete() }
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        screen(for: destination)
                            .onDisappear { router.navigationDidComplete() }
                    }
            }
        }

        @ViewBuilder
        private func screen(for destination: NavigationDestination) -> some View {
            switch destination {
            case .clock(let gameConfiguration):
                ClockView(presenter: dependencies.makeClockPresenter(gameConfiguration: gameConfiguration))
            }
        }

    }

}
