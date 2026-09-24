import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var session: AppSession
    @State private var registerMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var displayName = ""
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            LinearGradient(colors: [AppTheme.accent, AppTheme.secondary], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 22) {
                    Spacer(minLength: 35)
                    Image(systemName: "bubble.left.and.bubble.right.fill").font(.system(size: 56)).foregroundStyle(.white)
                    Text("Flow").font(.system(size: 44, weight: .bold, design: .rounded)).foregroundStyle(.white)
                    Text(registerMode ? "Создайте аккаунт Flow" : "Общайтесь. Быстро. Красиво.").foregroundStyle(.white.opacity(0.9))
                    VStack(spacing: 14) {
                        if registerMode {
                            TextField("Имя", text: $displayName)
                            TextField("Username", text: $username).textInputAutocapitalization(.never)
                        }
                        TextField("Email", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never).textContentType(.emailAddress)
                        SecureField("Пароль", text: $password).textContentType(registerMode ? .newPassword : .password)
                        Button(action: submit) {
                            Text(session.isLoading ? "Подождите…" : (registerMode ? "Создать аккаунт" : "Войти"))
                                .fontWeight(.bold).frame(maxWidth: .infinity).padding(.vertical, 15)
                                .background(.white, in: RoundedRectangle(cornerRadius: 16))
                                .foregroundStyle(AppTheme.accent)
                        }
                        if !errorMessage.isEmpty { Text(errorMessage).font(.footnote).foregroundStyle(.yellow).multilineTextAlignment(.center) }
                    }
                    .padding(20).background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 24))
                    .textFieldStyle(.plain).foregroundStyle(.white)
                    Button(registerMode ? "Уже есть аккаунт" : "Создать аккаунт") { withAnimation { registerMode.toggle(); errorMessage = "" } }
                        .foregroundStyle(.white)
                    Spacer(minLength: 20)
                }.padding(24)
            }
        }
    }

    private func submit() {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanEmail.contains("@"), password.count >= 6 else { errorMessage = "Введите корректный email и пароль минимум из 6 символов."; return }
        if registerMode {
            guard !cleanName.isEmpty, !cleanUsername.isEmpty else { errorMessage = "Заполните имя и username."; return }
            session.register(email: cleanEmail, password: password, username: cleanUsername, displayName: cleanName) { errorMessage = $0 ?? "" }
        } else {
            session.signIn(email: cleanEmail, password: password) { errorMessage = $0 ?? "" }
        }
    }
}
