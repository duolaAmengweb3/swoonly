import SwiftUI

/// Cover = real illustrated art (bundled) with a title scrim; gradient fallback if art missing. No glass.
struct StoryCover: View {
    @EnvironmentObject private var content: ContentStore
    let story: Story
    var width: CGFloat = 132
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomLeading) {
                if let img = content.cover(story.id) {
                    Image(uiImage: img).resizable().scaledToFill()
                        .frame(width: width, height: width * 1.48).clipped()
                } else {
                    let c = Theme.color(hex: story.accent)
                    Rectangle().fill(LinearGradient(colors: [c, c.opacity(0.62)],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: width, height: width * 1.48)
                }
                LinearGradient(colors: [.clear, .black.opacity(0.30), .black.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                    .frame(width: width, height: width * 1.48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(story.genre.uppercased())
                        .font(.caption2.weight(.bold)).tracking(1).foregroundStyle(.white.opacity(0.9))
                    // Full title, wrapping to as many lines as needed (scaled down a touch if very long) — never truncated.
                    Text(story.title)
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .lineLimit(4).minimumScaleFactor(0.6)
                        .fixedSize(horizontal: false, vertical: true)
                        .shadow(color: .black.opacity(0.5), radius: 2, y: 1)
                }.padding(12).frame(width: width, alignment: .leading)
            }
            .frame(width: width, height: width * 1.48)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.white.opacity(0.10), lineWidth: 0.8))
            .shadow(color: .black.opacity(0.18), radius: 9, y: 5)
            Text(story.author).font(.caption).foregroundStyle(Theme.textSecondary).lineLimit(1)
        }
        .frame(width: width)
    }
}

struct TagChip: View {
    let text: String
    var body: some View {
        Text(text).font(.caption2.weight(.medium)).foregroundStyle(Theme.textSecondary)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(Capsule().fill(Theme.surface)).overlay(Capsule().strokeBorder(Theme.hairline, lineWidth: 0.8))
    }
}

struct EmptyStateView: View {
    let symbol: String, title: String, message: String
    var cta: String? = nil
    var action: (() -> Void)? = nil
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: symbol).font(.system(size: 44)).foregroundStyle(Theme.accent.opacity(0.8))
            Text(title).font(.headline).foregroundStyle(Theme.textPrimary)
            Text(message).font(.subheadline).foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)
            if let cta, let action { Button(cta, action: action).buttonStyle(.borderedProminent).tint(Theme.accent) }
        }.padding(28).frame(maxWidth: .infinity)
    }
}
