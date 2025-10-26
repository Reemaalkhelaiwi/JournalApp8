import SwiftUI

struct MainPageView: View {
    var body: some View {
        EmptyStateScreen()
            .preferredColorScheme(.dark)
            .buttonStyle(.glass)
    }
}

#Preview {
    MainPageView()
        .preferredColorScheme(.dark)
        .buttonStyle(.glass)
}
