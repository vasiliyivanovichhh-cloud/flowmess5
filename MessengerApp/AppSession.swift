import Foundation
import FirebaseAuth

@MainActor
final class AppSession: ObservableObject {
    @Published var currentUser: User?
    @Published var chats: [Chat]
    @Published var messagesByChat: [String: [Message]]
    @Published var notificationsEnabled = true
    @Published var isLoading = false

    private let defaults = UserDefaults.standard
    private let userKey = "luma.currentUser"
    private let chatsKey = "luma.chats"
    private let messagesKey = "luma.messages"

    init() {
        currentUser = Self.load(User.self, key: userKey)
        chats = Self.load([Chat].self, key: chatsKey) ?? DemoData.chats
        messagesByChat = Self.load([String: [Message]].self, key: messagesKey) ?? ["anna-chat": DemoData.messages]
        if let firebaseUser = Auth.auth().currentUser {
            currentUser = User(
                id: firebaseUser.uid,
                username: firebaseUser.email?.split(separator: "@").first.map(String.init) ?? "new_user",
                displayName: firebaseUser.displayName ?? "Новый пользователь",
                email: firebaseUser.email ?? "",
                avatarSystemName: "person.crop.circle.fill"
            )
            save()
        }
    }

    func register(email: String, password: String, username: String, displayName: String, completion: @escaping (String?) -> Void) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                self.isLoading = false
                if let error {
                    completion(Self.authError(error))
                    return
                }
                guard let firebaseUser = result?.user else {
                    completion("Не удалось создать аккаунт.")
                    return
                }
                let changeRequest = firebaseUser.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { error in
                    Task { @MainActor in
                        if let error {
                            completion(Self.authError(error))
                            return
                        }
                        self.currentUser = User(id: firebaseUser.uid, username: username, displayName: displayName, email: email, avatarSystemName: "person.crop.circle.fill")
                        self.save()
                        completion(nil)
                    }
                }
            }
        }
    }

    func signIn(email: String, password: String, completion: @escaping (String?) -> Void) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                self.isLoading = false
                if let error {
                    completion(Self.authError(error))
                    return
                }
                guard let firebaseUser = result?.user else {
                    completion("Не удалось выполнить вход.")
                    return
                }
                self.currentUser = User(
                    id: firebaseUser.uid,
                    username: firebaseUser.email?.split(separator: "@").first.map(String.init) ?? "new_user",
                    displayName: firebaseUser.displayName ?? "Новый пользователь",
                    email: firebaseUser.email ?? email,
                    avatarSystemName: "person.crop.circle.fill"
                )
                self.save()
                completion(nil)
            }
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        currentUser = nil
        defaults.removeObject(forKey: userKey)
    }

    private static func authError(_ error: Error) -> String {
        let code = AuthErrorCode(rawValue: (error as NSError).code)
        switch code {
        case .emailAlreadyInUse: return "Эта почта уже зарегистрирована."
        case .invalidEmail: return "Введите корректный email."
        case .weakPassword: return "Пароль слишком слабый."
        case .wrongPassword, .userNotFound: return "Неверная почта или пароль."
        case .networkError: return "Нет соединения с Firebase."
        default: return error.localizedDescription
        }
    }

    func send(_ text: String, in chat: Chat, replyTo: Message? = nil, attachmentName: String? = nil) {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty || attachmentName != nil else { return }
        let message = Message(id: UUID().uuidString, text: cleanText, date: "сейчас", isMine: true, replyText: replyTo?.text, attachmentName: attachmentName)
        messagesByChat[chat.id, default: []].append(message)
        updateChat(chat, lastMessage: attachmentName == nil ? cleanText : "Вложение: \(attachmentName!)")
        save()
    }

    func updateMessage(_ message: Message, in chat: Chat, text: String) {
        guard var list = messagesByChat[chat.id], let index = list.firstIndex(where: { $0.id == message.id }) else { return }
        list[index].text = text
        list[index].isEdited = true
        messagesByChat[chat.id] = list
        save()
    }

    func deleteMessage(_ message: Message, in chat: Chat) {
        messagesByChat[chat.id]?.removeAll { $0.id == message.id }
        save()
    }

    func react(_ message: Message, in chat: Chat, emoji: String) {
        guard var list = messagesByChat[chat.id], let index = list.firstIndex(where: { $0.id == message.id }) else { return }
        list[index].reaction = list[index].reaction == emoji ? nil : emoji
        messagesByChat[chat.id] = list
        save()
    }

    private func updateChat(_ chat: Chat, lastMessage: String) {
        guard let index = chats.firstIndex(where: { $0.id == chat.id }) else { return }
        chats[index].lastMessage = lastMessage
        chats[index].date = "сейчас"
    }

    private func save() {
        Self.store(currentUser, key: userKey)
        Self.store(chats, key: chatsKey)
        Self.store(messagesByChat, key: messagesKey)
    }

    private static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private static func store<T: Encodable>(_ value: T?, key: String) {
        guard let value, let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
