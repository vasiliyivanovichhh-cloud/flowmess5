import Foundation

struct User: Identifiable, Hashable, Codable {
    let id: String
    var username: String
    var displayName: String
    var email: String
    var bio: String
    var avatarSystemName: String
}

struct Chat: Identifiable, Hashable, Codable {
    let id: String
    let user: User
    var lastMessage: String
    var date: String
    var unreadCount: Int
    var isOnline: Bool
}

struct Message: Identifiable, Hashable, Codable {
    let id: String
    var text: String
    var date: String
    let isMine: Bool
    var isEdited: Bool
    var replyText: String?
    var reaction: String?
    var attachmentName: String?
}

enum DemoData {
    static let anna = User(id: "anna", username: "anna_m", displayName: "Анна Морозова", email: "anna@example.com", bio: "Всегда на связи ✨", avatarSystemName: "sun.max.circle.fill")
    static let chats = [
        Chat(id: "anna-chat", user: anna, lastMessage: "Увидимся вечером ✨", date: "12:42", unreadCount: 2, isOnline: true),
        Chat(id: "team-chat", user: User(id: "team", username: "design_team", displayName: "Design Team", email: "", bio: "Команда Flow", avatarSystemName: "person.3.fill"), lastMessage: "Илья: отправил макеты", date: "Вчера", unreadCount: 0, isOnline: false),
        Chat(id: "max-chat", user: User(id: "max", username: "max_dev", displayName: "Макс Петров", email: "", bio: "Разработка и дизайн", avatarSystemName: "bolt.circle.fill"), lastMessage: "Спасибо, всё получил", date: "Пн", unreadCount: 0, isOnline: false)
    ]
    static let messages = [
        Message(id: "1", text: "Привет! Как твои дела?", date: "12:35", isMine: false, isEdited: false, replyText: nil, reaction: nil, attachmentName: nil),
        Message(id: "2", text: "Привет! Отлично, заканчиваю новый проект.", date: "12:37", isMine: true, isEdited: false, replyText: nil, reaction: nil, attachmentName: nil),
        Message(id: "3", text: "Увидимся вечером ✨", date: "12:42", isMine: false, isEdited: false, replyText: nil, reaction: nil, attachmentName: nil)
    ]
}
