import SwiftUI
import FirebaseCore

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
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
    static let accent = Color(red: 0.20, green: 0.43, blue: 0.96)
    static let secondary = Color(red: 0.34, green: 0.70, blue: 1.00)
    static let background = Color(uiColor: .systemGroupedBackground)
}
