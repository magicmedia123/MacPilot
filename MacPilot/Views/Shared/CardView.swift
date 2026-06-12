import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    var padding: CGFloat
    var hoverLift: Bool

    @State private var isHovered = false

    init(padding: CGFloat = 18, hoverLift: Bool = true, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.hoverLift = hoverLift
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                .background.secondary,
                in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                    .strokeBorder(.separator.opacity(0.4))
            }
            .shadow(color: .black.opacity(isHovered && hoverLift ? 0.07 : 0.03), radius: isHovered && hoverLift ? 9 : 4, y: 2)
            .animation(.easeOut(duration: 0.18), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color

    var body: some View {
        CardView {
            HStack(spacing: 13) {
                IconTile(systemImage: systemImage, tint: tint, size: 38)

                VStack(alignment: .leading, spacing: 3) {
                    Text(value)
                        .font(.title2.weight(.bold))
                        .contentTransition(.numericText())

                    Text(title)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
