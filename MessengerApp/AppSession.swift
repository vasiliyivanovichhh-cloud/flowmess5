import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class AppSession: ObservableObject {
    @Published var currentUser: User?
    @Published var chats: [Chat] = DemoData.chats
    @Published var messagesByChat: [String: [Message]] = ["anna-chat": DemoData.messages]
    @Published var isLoading = false

    private let defaults = UserDefaults.standard
    private let userKey = "flow.currentUser"
    private let chatsKey = "flow.chats"
    private let messagesKey = "flow.messages"
    private let db = Firestore.firestore()

    init() {
        currentUser = Self.load(User.self, key: userKey)
        chats = Self.load([Chat].self, key: chatsKey) ?? DemoData.chats
        messagesByChat = Self.load([String: [Message]].self, key: messagesKey) ?? ["anna-chat": DemoData.messages]
        if let firebaseUser = Auth.auth().currentUser { restoreFirebaseUser(firebaseUser) }
    }

    func register(email: String, password: String, username: String, displayName: String, completion: @escaping (String?) -> Void) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                if let error { self.isLoading = false; completion(Self.authError(error)); return }
                guard let firebaseUser = result?.user else { self.isLoading = false; completion("Не удалось создать аккаунт."); return }
                let request = firebaseUser.createProfileChangeRequest()
                request.displayName = displayName
                request.commitChanges { error in
                    Task { @MainActor in
                        self.isLoading = false
                        if let error { completion(Self.authError(error)); return }
                        self.currentUser = User(id: firebaseUser.uid, username: username, displayName: displayName, email: email, bio: "", avatarSystemName: "person.crop.circle.fill")
                        self.save()
                        self.syncUserToFirestore()
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
                if let error { completion(Self.authError(error)); return }
                guard let firebaseUser = result?.user else { completion("Не удалось выполнить вход."); return }
                self.restoreFirebaseUser(firebaseUser)
                completion(nil)
            }
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        currentUser = nil
        defaults.removeObject(forKey: userKey)
    }

    func send(_ text: String, in chat: Chat, replyTo: Message? = nil, attachmentName: String? = nil) {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty || attachmentName != nil else { return }
        let message = Message(id: UUID().uuidString, text: clean, date: "сейчас", isMine: true, isEdited: false, replyText: replyTo?.text, reaction: nil, attachmentName: attachmentName)
        messagesByChat[chat.id, default: []].append(message)
        updateChat(chat, lastMessage: attachmentName.map { "Вложение: \($0)" } ?? clean)
        save()
        if currentUser != nil {
            db.collection("chats").document(chat.id).collection("messages").document(message.id).setData([
                "text": message.text,
                "senderID": currentUser?.id ?? "",
                "replyText": message.replyText ?? "",
                "attachmentName": message.attachmentName ?? "",
                "createdAt": FieldValue.serverTimestamp()
            ])
        }
    }

    func updateMessage(_ message: Message, in chat: Chat, text: String) {
        guard var list = messagesByChat[chat.id], let index = list.firstIndex(where: { $0.id == message.id }) else { return }
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        list[index].text = value
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

    func updateProfile(displayName: String, username: String, bio: String) {
        guard var user = currentUser else { return }
        user.displayName = displayName
        user.username = username
        user.bio = bio
        currentUser = user
        save()
        syncUserToFirestore()
    }

    private func restoreFirebaseUser(_ firebaseUser: FirebaseAuth.User) {
        currentUser = User(id: firebaseUser.uid, username: firebaseUser.email?.split(separator: "@").first.map(String.init) ?? "user", displayName: firebaseUser.displayName ?? "Пользователь", email: firebaseUser.email ?? "", bio: "", avatarSystemName: "person.crop.circle.fill")
        save()
        syncUserToFirestore()
    }

    private func syncUserToFirestore() {
        guard let user = currentUser else { return }
        db.collection("users").document(user.id).setData(["username": user.username, "displayName": user.displayName, "email": user.email, "bio": user.bio], merge: true)
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

    private static func authError(_ error: Error) -> String {
        switch AuthErrorCode(rawValue: (error as NSError).code) {
        case .emailAlreadyInUse: return "Эта почта уже зарегистрирована."
        case .invalidEmail: return "Введите корректный email."
        case .weakPassword: return "Пароль слишком слабый."
        case .wrongPassword, .userNotFound: return "Неверная почта или пароль."
        case .networkError: return "Нет соединения с Firebase."
        default: return error.localizedDescription
        }
    }
}
