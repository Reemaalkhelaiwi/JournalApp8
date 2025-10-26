import SwiftUI

@main
struct JournalApp8App: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashScreen()
                        .preferredColorScheme(.dark)
                        .buttonStyle(.glass)// force dark mode for splash
                } else {
                    MainPageView()
                        .preferredColorScheme(.dark)
                        .buttonStyle(.glass)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSplash = false
                }
            }
        }
    }
}
