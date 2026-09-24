import SwiftUI
import FirebaseCore
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MessengerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var session = AppSession()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .tint(AppTheme.accent)
        }
    }
}

enum AppTheme {
    static let accent = Color(red: 0.31, green: 0.30, blue: 0.92)
    static let secondary = Color(red: 0.61, green: 0.38, blue: 0.98)
    static let background = Color(uiColor: .systemGroupedBackground)
}
