import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var progress: UserProgress
    @State private var page = 0
    @State private var selectedExperience = "Brand new"
    @State private var selectedApps: Set<String> = ["Office"]
    @State private var selectedGoal = "Everyday shortcuts"

    private let pages = [
        OnboardingPage(
            title: "Bring your Windows habits with you",
            message: "MacPilot starts from shortcuts you already know, then shows the Mac version.",
            symbolName: "keyboard"
        ),
        OnboardingPage(
            title: "How experienced are you with Mac?",
            message: "This helps MacPilot choose a friendly starting point.",
            symbolName: "person.crop.circle"
        ),
        OnboardingPage(
            title: "Which Windows apps did you use most?",
            message: "Your Windows background can shape future lesson recommendations.",
            symbolName: "square.grid.2x2"
        ),
        OnboardingPage(
            title: "What do you want to learn first?",
            message: "MacPilot will use this as your first learning focus.",
            symbolName: "target"
        ),
        OnboardingPage(
            title: "Practice in small lessons",
            message: "Complete one short lesson per day to build real Mac muscle memory.",
            symbolName: "flame"
        )
    ]

    private let experienceOptions = [
        "Brand new",
        "Some basics",
        "Comfortable"
    ]

    private let appOptions = [
        "Office",
        "Chrome",
        "File Explorer",
        "Outlook",
        "Teams",
        "Photoshop"
    ]

    private let goalOptions = [
        "Everyday shortcuts",
        "Find files and apps",
        "Switch apps faster",
        "Screenshots"
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    onboardingPage(for: index)
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
                .buttonStyle(BorderedProminentButtonStyle())
            }
            .padding(20)
        }
    }

    @ViewBuilder
    private func onboardingPage(for index: Int) -> some View {
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
                    .frame(maxWidth: 430)
            }

            switch index {
            case 1:
                SingleChoiceOptions(options: experienceOptions, selection: $selectedExperience)
            case 2:
                MultiChoiceOptions(options: appOptions, selections: $selectedApps)
            case 3:
                SingleChoiceOptions(options: goalOptions, selection: $selectedGoal)
            default:
                EmptyView()
            }
        }
    }
}

private struct SingleChoiceOptions: View {
    let options: [String]
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 10) {
            ForEach(options, id: \.self) { option in
                ChoiceButton(title: option, isSelected: selection == option) {
                    selection = option
                }
            }
        }
        .frame(maxWidth: 460)
    }
}

private struct MultiChoiceOptions: View {
    let options: [String]
    @Binding var selections: Set<String>

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: 10)], spacing: 10) {
            ForEach(options, id: \.self) { option in
                ChoiceButton(title: option, isSelected: selections.contains(option)) {
                    if selections.contains(option) {
                        selections.remove(option)
                    } else {
                        selections.insert(option)
                    }
                }
            }
        }
        .frame(maxWidth: 460)
    }
}

private struct ChoiceButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                }

                Text(title)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .background(Color.secondary.opacity(isSelected ? 0.16 : 0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(isSelected ? Color.blue : Color.secondary.opacity(0.25))
            }
        }
        .buttonStyle(PlainButtonStyle())
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
