import SwiftUI

struct AvatarView: View {
    let user: User
    let size: CGFloat
    let online: Bool

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: user.avatarSystemName)
                .font(.system(size: size * 0.48))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(
                    LinearGradient(colors: [AppTheme.secondary, AppTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: Circle()
                )
            if online {
                Circle()
                    .fill(.green)
                    .frame(width: size * 0.27, height: size * 0.27)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
            }
        }
    }
}

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

