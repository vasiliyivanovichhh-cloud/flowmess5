import SwiftUI
import UniformTypeIdentifiers

struct ChatView: View {
    @EnvironmentObject private var session: AppSession
    let chat: Chat
    @State private var text = ""
    @State private var editingMessage: Message?
    @State private var replyMessage: Message?
    @State private var showFilePicker = false

    private var messages: [Message] { session.messagesByChat[chat.id] ?? [] }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isMine { Spacer(minLength: 40) }
                                VStack(alignment: message.isMine ? .trailing : .leading, spacing: 4) {
                                    if let replyText = message.replyText {
                                        Text("Ответ: \(replyText)").font(.caption).foregroundStyle(.secondary)
                                    }
                                    .contextMenu {
                                        Button("Ответить", systemImage: "arrowshape.turn.up.left") { replyMessage = message }
                                        Button("Реакция ❤️", systemImage: "heart") { session.react(message, in: chat, emoji: "❤️") }
                                        if message.isMine {
                                            Button("Изменить", systemImage: "pencil") { editingMessage = message }
                                            Button("Удалить", systemImage: "trash", role: .destructive) { session.deleteMessage(message, in: chat) }
                                        }
                                    }
                                    if let attachmentName = message.attachmentName {
                                        Label(attachmentName, systemImage: "paperclip")
                                            .font(.subheadline)
                                    }
                                    Text(message.text)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 11)
                                        .foregroundStyle(message.isMine ? .white : .primary)
                                        .background(message.isMine ? AppTheme.accent : Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
                                    HStack(spacing: 5) {
                                        Text(message.date)
                                        if message.isEdited { Text("изменено") }
                                    }.font(.caption2).foregroundStyle(.secondary)
                                    if let reaction = message.reaction {
                                        Text(reaction).font(.caption).padding(4).background(.thinMaterial, in: Capsule())
                                    }
                                }
                                if !message.isMine { Spacer(minLength: 40) }
                            }
                        }
                    }
                    .padding()
                }
                if let replyMessage {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.left.fill")
                        Text(replyMessage.text.isEmpty ? "Вложение" : replyMessage.text)
                            .lineLimit(1)
                        Spacer()
                        Button { self.replyMessage = nil } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                }
                HStack(spacing: 10) {
                    TextField("Сообщение", text: $text, axis: .vertical)
                        .padding(11)
                        .background(Color(uiColor: .secondarySystemGroupedBackground), in: Capsule())
                    Menu {
                        Button("Фото или видео", systemImage: "photo") { showFilePicker = true }
                        Button("Файл", systemImage: "doc") { showFilePicker = true }
                    } label: {
                        Image(systemName: "paperclip").font(.system(size: 20))
                    }
                    Button {
                        session.send(text, in: chat, replyTo: replyMessage)
                        text = ""
                        replyMessage = nil
                    } label: {
                        Image(systemName: "arrow.up.circle.fill").font(.system(size: 32))
                    }
                }
                .padding()
            }
            .alert("Изменить сообщение", isPresented: Binding(get: { editingMessage != nil }, set: { if !$0 { editingMessage = nil } })) {
                TextField("Текст", text: Binding(get: { editingMessage?.text ?? "" }, set: { editingMessage?.text = $0 }))
                Button("Сохранить") {
                    if let message = editingMessage { session.updateMessage(message, in: chat, text: message.text) }
                    editingMessage = nil
                }
                Button("Отмена", role: .cancel) { editingMessage = nil }
            }
            .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.image, .movie, .data]) { result in
                if case .success(let url) = result {
                    session.send("", in: chat, attachmentName: url.lastPathComponent)
                }
            }
            .navigationTitle(chat.user.displayName)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
