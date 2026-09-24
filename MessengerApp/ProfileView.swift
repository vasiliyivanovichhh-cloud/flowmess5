import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: AppSession
    @AppStorage("luma.notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("luma.darkMode") private var darkMode = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 10) {
                        if let user = session.currentUser {
                            AvatarView(user: user, size: 92, online: true)
                            Text(user.displayName).font(.title2.bold())
                            Text("@\(user.username)").foregroundStyle(.secondary)
                            Text(user.email).font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                Section("Настройки") {
                    Toggle("Уведомления", isOn: $notificationsEnabled)
                    Toggle("Тёмная тема", isOn: $darkMode)
                    Label("Конфиденциальность", systemImage: "lock.fill")
                    Label("О приложении", systemImage: "info.circle.fill")
                }
                Section {
                    Button("Выйти", role: .destructive) { session.signOut() }
                }
            }
            .navigationTitle("Профиль")
            .preferredColorScheme(darkMode ? .dark : nil)
        }
    }
}
