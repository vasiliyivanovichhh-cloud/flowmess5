import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: AppSession
    var body: some View {
        Group {
            if session.currentUser == nil { AuthView() } else { MainTabView() }
        }.animation(.easeInOut(duration: 0.2), value: session.currentUser)
    }
}
