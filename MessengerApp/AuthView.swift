import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var session: AppSession
    @State private var isRegistering = false
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var displayName = ""
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            LinearGradient(colors: [AppTheme.accent, AppTheme.secondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 22) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 54))
                        .foregroundStyle(.white)
                        .padding(.top, 55)
                    Text("Luma")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(isRegistering ? "Создайте свой аккаунт" : "Общайтесь легко и красиво")
                        .foregroundStyle(.white.opacity(0.85))
                    VStack(spacing: 14) {
                        if isRegistering {
                            TextField("Ваше имя", text: $displayName)
                                .textContentType(.name)
                            TextField("Имя пользователя", text: $username)
                                .textContentType(.username)
                        }
                        TextField("Электронная почта", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        SecureField("Пароль", text: $password)
                            .textContentType(isRegistering ? .newPassword : .password)
                        Button {
                            let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                            if cleanEmail.isEmpty || !cleanEmail.contains("@") || password.count < 6 {
                                errorMessage = "Введите корректную почту и пароль минимум из 6 символов."
                            } else if isRegistering && (displayName.isEmpty || username.isEmpty) {
                                errorMessage = "Заполните имя и username."
                            } else if isRegistering {
                                session.register(email: cleanEmail, password: password, username: username, displayName: displayName) { error in
                                    errorMessage = error ?? ""
                                }
                            } else {
                                session.signIn(email: cleanEmail, password: password) { error in
                                    errorMessage = error ?? ""
                                }
                            }
                        } label: {
                            Text(session.isLoading ? "Подождите…" : (isRegistering ? "Создать аккаунт" : "Войти"))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(.white)
                                .foregroundStyle(AppTheme.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        if !errorMessage.isEmpty {
                            Text(errorMessage).font(.footnote).foregroundStyle(.yellow)
                        }
                    }
                    .padding(20)
                    .background(.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 24))
                    .textFieldStyle(.plain)
                    .foregroundStyle(.white)
                    Button(isRegistering ? "У меня уже есть аккаунт" : "Создать новый аккаунт") {
                        withAnimation { isRegistering.toggle() }
                    }
                    .foregroundStyle(.white)
                }
                .padding(24)
            }
        }
    }
}
