import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: AppSession
    @AppStorage("flow.darkMode") private var darkMode = false
    @AppStorage("flow.notifications") private var notifications = true
    @State private var editing = false

    var body: some View {
        NavigationStack {
            Form {
                if let user = session.currentUser {
                    Section {
                        VStack(spacing: 9) {
                            AvatarView(user: user, size: 96, online: true)
                            Text(user.displayName).font(.title2.bold())
                            Text("@\(user.username)").foregroundStyle(.secondary)
                            if !user.bio.isEmpty { Text(user.bio).font(.subheadline).foregroundStyle(.secondary) }
                            Text(user.email).font(.footnote).foregroundStyle(.secondary)
                        }.frame(maxWidth: .infinity).padding(.vertical, 12)
                    }
                    Section { Button("Редактировать профиль") { editing = true } }
                }
                Section("Настройки") {
                    Toggle("Уведомления", isOn: $notifications)
                    Toggle("Тёмная тема", isOn: $darkMode)
                    Label("Конфиденциальность", systemImage: "lock.fill")
                    Label("Безопасность", systemImage: "checkmark.shield.fill")
                }
                Section("О Flow") {
                    LabeledContent("Версия", value: "1.0")
                    Text("Flow Messenger — современный мессенджер без звонков.")
                }
                Section { Button("Выйти", role: .destructive) { session.signOut() } }
            }.navigationTitle("Профиль").preferredColorScheme(darkMode ? .dark : nil)
            .sheet(isPresented: $editing) { EditProfileView().environmentObject(session) }
        }
    }
}

struct EditProfileView: View {
    @EnvironmentObject private var session: AppSession
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var username = ""
    @State private var bio = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Имя", text: $name)
                TextField("Username", text: $username).textInputAutocapitalization(.never)
                TextField("О себе", text: $bio, axis: .vertical).lineLimit(2...5)
            }.navigationTitle("Профиль")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Сохранить") { session.updateProfile(displayName: name, username: username, bio: bio); dismiss() } }
            }
            .onAppear { if let user = session.currentUser { name = user.displayName; username = user.username; bio = user.bio } }
        }
    }
}
