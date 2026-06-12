import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var progress: UserProgress

    @State private var page = 0
    @State private var goingForward = true
    @State private var selectedExperience = "Brand new"
    @State private var selectedApps: Set<String> = ["Office"]
    @State private var selectedGoal = "Everyday shortcuts"

    private let pages = [
        OnboardingPage(
            title: "Bring your Windows habits with you",
            message: "MacPilot starts from shortcuts you already know, then shows you the Mac way — one short lesson at a time.",
            symbolName: "keyboard",
            tint: .blue
        ),
        OnboardingPage(
            title: "How experienced are you with Mac?",
            message: "This helps MacPilot choose a friendly starting point.",
            symbolName: "person.crop.circle",
            tint: .indigo
        ),
        OnboardingPage(
            title: "Which Windows apps did you use most?",
            message: "Your background shapes which lessons we recommend first.",
            symbolName: "square.grid.2x2",
            tint: .teal
        ),
        OnboardingPage(
            title: "What do you want to learn first?",
            message: "We'll make this your first learning focus.",
            symbolName: "target",
            tint: .orange
        ),
        OnboardingPage(
            title: "Practice in small daily lessons",
            message: "One short lesson a day builds real Mac muscle memory — and keeps your streak alive.",
            symbolName: "flame.fill",
            tint: .red
        )
    ]

    // These option strings are persisted and matched by DashboardViewModel's
    // recommendation logic — keep both sides in sync.
    private let experienceOptions: [(String, String)] = [
        ("Brand new", "sparkles"),
        ("Some basics", "book"),
        ("Comfortable", "checkmark.seal")
    ]

    private let appOptions: [(String, String)] = [
        ("Office", "doc.text"),
        ("Chrome", "globe"),
        ("File Explorer", "folder"),
        ("Outlook", "envelope"),
        ("Teams", "person.2"),
        ("Photoshop", "photo")
    ]

    private let goalOptions: [(String, String)] = [
        ("Everyday shortcuts", "command"),
        ("Find files and apps", "magnifyingglass"),
        ("Switch apps faster", "rectangle.2.swap"),
        ("Screenshots", "camera.viewfinder")
    ]

    var body: some View {
        VStack(spacing: 0) {
            ProgressView(value: Double(page + 1), total: Double(pages.count))
                .tint(pages[page].tint)
                .controlSize(.small)
                .padding(.horizontal, 24)
                .padding(.top, 18)

            ZStack {
                pageContent(for: page)
                    .id(page)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: goingForward ? .trailing : .leading).combined(with: .opacity),
                            removal: .move(edge: goingForward ? .leading : .trailing).combined(with: .opacity)
                        )
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 36)
            .animation(.easeInOut(duration: 0.32), value: page)

            Divider()

            footer
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var footer: some View {
        HStack {
            if page > 0 {
                Button("Back") {
                    goingForward = false
                    page -= 1
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            PageDots(count: pages.count, selectedIndex: page)

            Spacer()

            Button(page == pages.count - 1 ? "Start Learning" : "Continue") {
                goingForward = true
                if page == pages.count - 1 {
                    progress.completeOnboarding(
                        macExperienceLevel: selectedExperience,
                        windowsAppsUsed: Array(selectedApps).sorted(),
                        learningGoal: selectedGoal
                    )
                    dismiss()
                } else {
                    page += 1
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut(.defaultAction)
        }
        .padding(18)
    }

    @ViewBuilder
    private func pageContent(for index: Int) -> some View {
        VStack(spacing: 24) {
            Spacer(minLength: 0)

            IconTile(systemImage: pages[index].symbolName, tint: pages[index].tint, size: 84, cornerRadius: 20)
                .shadow(color: pages[index].tint.opacity(0.35), radius: 12, y: 5)

            VStack(spacing: 10) {
                Text(pages[index].title)
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)

                Text(pages[index].message)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 440)
                    .fixedSize(horizontal: false, vertical: true)
            }

            switch index {
            case 1:
                SingleChoiceOptions(options: experienceOptions, selection: $selectedExperience, tint: pages[index].tint)
            case 2:
                MultiChoiceOptions(options: appOptions, selections: $selectedApps, tint: pages[index].tint)
            case 3:
                SingleChoiceOptions(options: goalOptions, selection: $selectedGoal, tint: pages[index].tint)
            default:
                EmptyView()
            }

            Spacer(minLength: 0)
        }
    }
}

private struct SingleChoiceOptions: View {
    let options: [(String, String)]
    @Binding var selection: String
    var tint: Color

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
            ForEach(options, id: \.0) { option, symbol in
                ChoiceCard(title: option, symbolName: symbol, tint: tint, isSelected: selection == option) {
                    selection = option
                }
            }
        }
        .frame(maxWidth: 500)
    }
}

private struct MultiChoiceOptions: View {
    let options: [(String, String)]
    @Binding var selections: Set<String>
    var tint: Color

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
            ForEach(options, id: \.0) { option, symbol in
                ChoiceCard(title: option, symbolName: symbol, tint: tint, isSelected: selections.contains(option)) {
                    if selections.contains(option) {
                        selections.remove(option)
                    } else {
                        selections.insert(option)
                    }
                }
            }
        }
        .frame(maxWidth: 500)
    }
}

private struct ChoiceCard: View {
    let title: String
    let symbolName: String
    let tint: Color
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: symbolName)
                        .font(.system(size: 21, weight: .medium))
                        .foregroundStyle(isSelected ? tint : .secondary)
                        .frame(height: 26)
                }

                Text(title)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
            .background(
                isSelected ? tint.opacity(0.12) : Color.secondary.opacity(isHovered ? 0.1 : 0.06),
                in: RoundedRectangle(cornerRadius: 11, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .strokeBorder(isSelected ? tint : Color.secondary.opacity(0.25), lineWidth: isSelected ? 1.5 : 1)
            }
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white, tint)
                        .padding(6)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.25), value: isSelected)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

private struct OnboardingPage {
    let title: String
    let message: String
    let symbolName: String
    let tint: Color
}

private struct PageDots: View {
    let count: Int
    let selectedIndex: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == selectedIndex ? Color.accentColor : Color.secondary.opacity(0.25))
                    .frame(width: index == selectedIndex ? 18 : 7, height: 7)
                    .animation(.spring(duration: 0.3), value: selectedIndex)
            }
        }
        .accessibilityLabel("Onboarding page \(selectedIndex + 1) of \(count)")
    }
}
