import SwiftUI

@main
struct HelloFlowApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 18) {
                Image(systemName: "hand.wave.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)

                Text("Привет!")
                    .font(.system(size: 42, weight: .bold))

                Text("Это настоящее iOS-приложение.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        }
    }
}
