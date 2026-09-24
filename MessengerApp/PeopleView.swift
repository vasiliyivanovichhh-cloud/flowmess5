import SwiftUI

struct PeopleView: View {
    @State private var query = ""
    let people = [DemoData.anna, User(id: "sofia", username: "sofia_art", displayName: "София Волкова", email: "", avatarSystemName: "paintpalette.fill"), User(id: "ilya", username: "ilya_pm", displayName: "Илья Смирнов", email: "", avatarSystemName: "sparkles")]

    var body: some View {
        NavigationStack {
            List(people.filter { query.isEmpty || $0.displayName.localizedCaseInsensitiveContains(query) || $0.username.localizedCaseInsensitiveContains(query) }) { person in
                HStack(spacing: 14) {
                    AvatarView(user: person, size: 50, online: person.id == "anna")
                    VStack(alignment: .leading, spacing: 3) {
                        Text(person.displayName).font(.headline)
                        Text("@\(person.username)").font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "message.fill")
                        .foregroundStyle(AppTheme.accent)
                }
                .padding(.vertical, 5)
            }
            .listStyle(.plain)
            .navigationTitle("Люди")
            .searchable(text: $query, prompt: "Имя или @username")
        }
    }
}

