import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct ChatView: View {
    @EnvironmentObject private var session: AppSession
    let chat: Chat
    @State private var text = ""
    @State private var editingMessage: Message?
    @State private var replyMessage: Message?
    @State private var showFilePicker = false

    private var messages: [Message] { session.messagesByChat[chat.id] ?? [] }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        messageRow(message)
                    }
                }.padding()
            }
            if let replyMessage {
                HStack(spacing: 8) {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                    Text(replyMessage.text.isEmpty ? "Вложение" : replyMessage.text).lineLimit(1)
                    Spacer()
                    Button { self.replyMessage = nil } label: { Image(systemName: "xmark.circle.fill") }
                }.font(.caption).foregroundStyle(.secondary).padding(.horizontal).padding(.bottom, 6)
            }
            HStack(spacing: 8) {
                Menu {
                    Button("Фото или видео", systemImage: "photo") { showFilePicker = true }
                    Button("Файл", systemImage: "doc") { showFilePicker = true }
                } label: { Image(systemName: "paperclip").font(.system(size: 19)) }
                TextField("Сообщение", text: $text, axis: .vertical)
                    .lineLimit(1...5).padding(.horizontal, 13).padding(.vertical, 10)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
                Button {
                    session.send(text, in: chat, replyTo: replyMessage)
                    text = ""; replyMessage = nil
                } label: { Image(systemName: "arrow.up.circle.fill").font(.system(size: 32)) }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }.padding()
        }
        .background(AppTheme.background)
        .navigationTitle(chat.user.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Изменить сообщение", isPresented: Binding(get: { editingMessage != nil }, set: { if !$0 { editingMessage = nil } })) {
            TextField("Текст", text: Binding(get: { editingMessage?.text ?? "" }, set: { editingMessage?.text = $0 }))
            Button("Сохранить") { if let message = editingMessage { session.updateMessage(message, in: chat, text: message.text) }; editingMessage = nil }
            Button("Отмена", role: .cancel) { editingMessage = nil }
        }
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.image, .movie, .audio, .pdf, .data]) { result in
            if case .success(let url) = result { session.send("", in: chat, attachmentName: url.lastPathComponent) }
        }
    }

    @ViewBuilder
    private func messageRow(_ message: Message) -> some View {
        HStack {
            if message.isMine { Spacer(minLength: 42) }
            VStack(alignment: message.isMine ? .trailing : .leading, spacing: 5) {
                if let reply = message.replyText { Text("↩︎ (reply)").font(.caption).foregroundStyle(.secondary).lineLimit(2) }
                if let attachment = message.attachmentName { Label(attachment, systemImage: "paperclip").font(.subheadline).padding(8).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10)) }
                if !message.text.isEmpty {
                    Text(message.text).padding(.horizontal, 15).padding(.vertical, 11)
                        .foregroundStyle(message.isMine ? .white : .primary)
                        .background(message.isMine ? AppTheme.accent : Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
                }
                HStack(spacing: 4) { Text(message.date); if message.isEdited { Text("изменено") } }
                    .font(.caption2).foregroundStyle(.secondary)
                if let reaction = message.reaction { Text(reaction).padding(4).background(.thinMaterial, in: Capsule()) }
            }
            .contextMenu {
                Button("Ответить", systemImage: "arrowshape.turn.up.left") { replyMessage = message }
                Button("Реакция ❤️", systemImage: "heart") { session.react(message, in: chat, emoji: "❤️") }
                Button("Копировать", systemImage: "doc.on.doc") { UIPasteboard.general.string = message.text }
                if message.isMine {
                    Button("Изменить", systemImage: "pencil") { editingMessage = message }
                    Button("Удалить", systemImage: "trash", role: .destructive) { session.deleteMessage(message, in: chat) }
                }
            }
            if !message.isMine { Spacer(minLength: 42) }
        }
    }
}
