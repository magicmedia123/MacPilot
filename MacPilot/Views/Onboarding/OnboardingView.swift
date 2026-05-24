import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var progress: UserProgress
    @State private var page = 0

    private let pages = [
        OnboardingPage(
            title: "Bring your Windows habits with you",
            message: "MacPilot starts from shortcuts and gestures you already know, then shows the Mac version.",
            symbolName: "keyboard"
        ),
        OnboardingPage(
            title: "Practice in small lessons",
            message: "Each lesson is short, focused, and built around one practical Mac habit.",
            symbolName: "rectangle.stack"
        ),
        OnboardingPage(
            title: "Build a streak",
            message: "Complete lessons across days to keep your practice streak alive.",
            symbolName: "flame"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    VStack(spacing: 22) {
                        Image(systemName: pages[index].symbolName)
                            .font(.system(size: 54, weight: .medium))
                            .foregroundStyle(.blue)
                            .frame(width: 96, height: 96)
                            .background(.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                        VStack(spacing: 10) {
                            Text(pages[index].title)
                                .font(.title.weight(.semibold))
                                .multilineTextAlignment(.center)

                            Text(pages[index].message)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 420)
                        }
                    }
                    .padding(36)
                    .tag(index)
                }
            }
            .tabViewStyle(.automatic)

            Divider()

            HStack {
                PageDots(count: pages.count, selectedIndex: page)

                Spacer()

                Button(page == pages.count - 1 ? "Start Learning" : "Next") {
                    if page == pages.count - 1 {
                        progress.completeOnboarding()
                        dismiss()
                    } else {
                        page += 1
                    }
                }
                .buttonStyle(BorderedProminentButtonStyle())
            }
            .padding(20)
        }
    }
}

private struct OnboardingPage {
    let title: String
    let message: String
    let symbolName: String
}

private struct PageDots: View {
    let count: Int
    let selectedIndex: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == selectedIndex ? Color.accentColor : Color.secondary.opacity(0.25))
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityLabel("Onboarding page \(selectedIndex + 1) of \(count)")
    }
}
