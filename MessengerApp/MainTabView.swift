import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ChatsView().tabItem { Label("Чаты", systemImage: "bubble.left.and.bubble.right.fill") }
            PeopleView().tabItem { Label("Люди", systemImage: "person.2.fill") }
            ProfileView().tabItem { Label("Профиль", systemImage: "person.crop.circle.fill") }
        }
    }
}

struct ChatsView: View {
    @EnvironmentObject private var session: AppSession
    @State private var query = ""
    @State private var selectedChat: Chat?

    private var filtered: [Chat] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return session.chats }
        return session.chats.filter { $0.user.displayName.localizedCaseInsensitiveContains(q) || $0.user.username.localizedCaseInsensitiveContains(q) || $0.lastMessage.localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { chat in
                Button { selectedChat = chat } label: {
                    HStack(spacing: 13) {
                        AvatarView(user: chat.user, size: 54, online: chat.isOnline)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(chat.user.displayName).font(.headline).foregroundStyle(.primary)
                            Text(chat.lastMessage).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 7) {
                            Text(chat.date).font(.caption).foregroundStyle(.secondary)
                            if chat.unreadCount > 0 { Text("\(chat.unreadCount)").font(.caption2.bold()).foregroundStyle(.white).frame(width: 22, height: 22).background(AppTheme.accent, in: Circle()) }
                        }
                    }.padding(.vertical, 5)
                }
            }
            .listStyle(.plain).navigationTitle("Flow").searchable(text: $query, prompt: "Поиск по чатам")
            .sheet(item: $selectedChat) { chat in NavigationStack { ChatView(chat: chat) } }
        }
    }
}
