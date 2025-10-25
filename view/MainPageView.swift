import SwiftUI

struct MainPageView: View {
    var body: some View {
        EmptyStateScreen()
            .preferredColorScheme(.dark)
    }
}

#Preview {
    MainPageView()
        .preferredColorScheme(.dark)
}
