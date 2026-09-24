import SwiftUI

struct AvatarView: View {
    let user: User
    let size: CGFloat
    let online: Bool

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: user.avatarSystemName)
                .font(.system(size: size * 0.45, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(LinearGradient(colors: [AppTheme.secondary, AppTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing), in: Circle())
            if online {
                Circle().fill(.green).frame(width: size * 0.25, height: size * 0.25)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
            }
        }
    }
}

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content.padding().background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage).font(.system(size: 44)).foregroundStyle(AppTheme.accent)
            Text(title).font(.title3.bold())
            Text(subtitle).multilineTextAlignment(.center).foregroundStyle(.secondary)
        }.padding(30)
    }
}
