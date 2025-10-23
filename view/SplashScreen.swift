import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            // system background (adapts to dark/light mode)
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image("JournalIcon") // your app icon asset
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                Text("Journali")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.primary) // adjusts automatically for dark mode

                Text("Your thoughts, your story")
                    .foregroundColor(.secondary)
                    .font(.system(size: 18))
            }
        }
    }
}

#Preview {
    SplashScreen()
        .preferredColorScheme(.dark)
}
