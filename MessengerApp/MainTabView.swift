import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ChatsView()
                .tabItem { Label("Чаты", systemImage: "bubble.left.and.bubble.right.fill") }
            PeopleView()
                .tabItem { Label("Люди", systemImage: "person.2.fill") }
            ProfileView()
                .tabItem { Label("Профиль", systemImage: "person.crop.circle.fill") }
        }
    }
}

struct ChatsView: View {
    @EnvironmentObject private var session: AppSession
    @State private var query = ""
    @State private var selectedChat: Chat?

    var filteredChats: [Chat] {
        query.isEmpty ? session.chats : session.chats.filter { $0.user.displayName.localizedCaseInsensitiveContains(query) || $0.user.username.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            List(filteredChats) { chat in
                Button { selectedChat = chat } label: {
                    HStack(spacing: 13) {
                        AvatarView(user: chat.user, size: 52, online: chat.isOnline)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(chat.user.displayName).font(.headline).foregroundStyle(.primary)
                            Text(chat.lastMessage).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 7) {
                            Text(chat.date).font(.caption).foregroundStyle(.secondary)
                            if chat.unreadCount > 0 {
                                Text("\(chat.unreadCount)")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                                    .frame(width: 22, height: 22)
                                    .background(AppTheme.accent, in: Circle())
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Сообщения")
            .searchable(text: $query, prompt: "Поиск по чатам")
            .sheet(item: $selectedChat) { ChatView(chat: $0) }
        }
    }
}
