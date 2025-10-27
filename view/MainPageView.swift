import SwiftUI

struct MainPageView: View {
    var body: some View {
        EmptyStateView()
            .preferredColorScheme(.dark)
          
    }
}

#Preview {
    MainPageView()
        .preferredColorScheme(.dark)
       
}
