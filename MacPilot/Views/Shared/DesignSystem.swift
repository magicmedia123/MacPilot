import SwiftUI

// MARK: - Theme

enum AppTheme {
    static let accentGradient = LinearGradient(
        colors: [Color.blue, Color.indigo],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardCornerRadius: CGFloat = 14

    static func iconGradient(for tint: Color) -> LinearGradient {
        LinearGradient(
            colors: [tint, tint.opacity(0.72)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

/// User-selectable appearance, persisted via AppStorage("appearanceMode").
enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var symbolName: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }
}

extension LessonCategory {
    var tint: Color {
        switch self {
        case .shortcuts: .blue
        case .gestures: .teal
        case .navigation: .orange
        case .productivity: .purple
        }
    }

    var shortName: String {
        switch self {
        case .shortcuts: "Shortcuts"
        case .gestures: "Gestures"
        case .navigation: "Navigation"
        case .productivity: "Productivity"
        }
    }
}

extension LessonDifficulty {
    var tint: Color {
        switch self {
        case .beginner: .green
        case .comfortable: .orange
        case .advanced: .purple
        }
    }

    var symbolName: String {
        switch self {
        case .beginner: "leaf"
        case .comfortable: "gauge.with.dots.needle.50percent"
        case .advanced: "bolt"
        }
    }
}

// MARK: - Icon tile

/// A rounded-square icon on a tinted gradient, in the style of System Settings sidebar icons.
struct IconTile: View {
    let systemImage: String
    var tint: Color = .blue
    var size: CGFloat = 38
    var cornerRadius: CGFloat = 9

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.48, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                AppTheme.iconGradient(for: tint),
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .shadow(color: tint.opacity(0.3), radius: 3, y: 1)
    }
}

// MARK: - Chips and badges

struct MetaChip: View {
    let text: String
    var systemImage: String?
    var tint: Color = .secondary

    var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 9, weight: .semibold))
            }
            Text(text)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tint.opacity(0.12), in: Capsule())
    }
}

struct DifficultyBadge: View {
    let difficulty: LessonDifficulty

    var body: some View {
        MetaChip(
            text: difficulty.rawValue,
            systemImage: difficulty.symbolName,
            tint: difficulty.tint
        )
    }
}

// MARK: - Keycaps

/// A single key rendered like a physical keyboard keycap.
/// `prominent` keys mimic dark MacBook keys; standard keys look like light PC keys.
struct KeyCap: View {
    let text: String
    var prominent: Bool = false
    var large: Bool = false

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text(text)
            .font(.system(size: large ? 17 : 12.5, weight: .semibold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(prominent ? Color.white : Color.primary)
            .frame(minWidth: large ? 26 : 16)
            .padding(.horizontal, large ? 10 : 7)
            .padding(.vertical, large ? 8 : 5)
            .background(keyFill, in: RoundedRectangle(cornerRadius: large ? 8 : 6, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: large ? 8 : 6, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1)
            }
            .shadow(color: .black.opacity(prominent ? 0.35 : 0.16), radius: 0.5, y: large ? 2 : 1.5)
    }

    private var keyFill: LinearGradient {
        if prominent {
            return LinearGradient(
                colors: [Color(white: 0.26), Color(white: 0.13)],
                startPoint: .top,
                endPoint: .bottom
            )
        }

        let top = colorScheme == .dark ? Color(white: 0.32) : Color(white: 0.99)
        let bottom = colorScheme == .dark ? Color(white: 0.24) : Color(white: 0.91)
        return LinearGradient(colors: [top, bottom], startPoint: .top, endPoint: .bottom)
    }

    private var borderColor: Color {
        if prominent {
            return Color.white.opacity(0.18)
        }
        return colorScheme == .dark ? Color.white.opacity(0.14) : Color.black.opacity(0.12)
    }
}

/// Renders a shortcut string ("Command + Shift + 5") as a row of keycaps.
/// Falls back to a labeled pill for instructions that are not plain key combos
/// (gestures, multi-option text, and so on).
struct ShortcutDisplay: View {
    enum Style {
        case mac
        case windows
    }

    let text: String
    var style: Style = .mac
    var fallbackIcon: String = "keyboard"
    var large: Bool = false

    var body: some View {
        if let groups = ShortcutParser.keycapGroups(from: text, style: style) {
            HStack(spacing: large ? 7 : 5) {
                ForEach(Array(groups.enumerated()), id: \.offset) { groupIndex, group in
                    if groupIndex > 0 {
                        Text("then")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    ForEach(Array(group.enumerated()), id: \.offset) { _, key in
                        KeyCap(text: key, prominent: style == .mac, large: large)
                    }
                }
            }
        } else {
            HStack(spacing: 6) {
                Image(systemName: fallbackIcon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(style == .mac ? Color.accentColor : Color.secondary)

                Text(text)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.quaternary.opacity(0.6), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
    }
}

enum ShortcutParser {
    /// Parses a shortcut string into groups of keycap labels.
    /// Returns nil when the string is not a plain key combination, so callers can
    /// fall back to descriptive text (for example trackpad gestures).
    static func keycapGroups(from text: String, style: ShortcutDisplay.Style) -> [[String]]? {
        let segments = text.components(separatedBy: ", then ")
        guard segments.count <= 2 else { return nil }

        var groups: [[String]] = []
        for segment in segments {
            guard !segment.contains("("), !segment.contains(",") else { return nil }
            guard let keys = parseCombo(segment, style: style) else { return nil }
            groups.append(keys)
        }
        return groups
    }

    private static func parseCombo(_ combo: String, style: ShortcutDisplay.Style) -> [String]? {
        let parts = combo
            .components(separatedBy: "+")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard !parts.isEmpty, parts.count <= 4, !parts.contains(where: \.isEmpty) else { return nil }

        var keys: [String] = []
        for part in parts {
            guard let display = displayLabel(for: part, style: style) else { return nil }
            keys.append(display)
        }
        return keys
    }

    private static func displayLabel(for token: String, style: ShortcutDisplay.Style) -> String? {
        let lower = token.lowercased()

        // Tokens with embedded alternatives or descriptions are not single keys.
        guard !lower.contains(" or "), !lower.contains("(") else { return nil }

        switch lower {
        case "command", "cmd":
            return style == .mac ? "⌘" : "Cmd"
        case "shift":
            return style == .mac ? "⇧" : "Shift"
        case "option":
            return "⌥"
        case "alt":
            return style == .mac ? "⌥" : "Alt"
        case "control":
            return style == .mac ? "⌃" : "Ctrl"
        case "ctrl":
            return style == .mac ? "⌃" : "Ctrl"
        case "win", "windows":
            return "Win"
        case "space":
            return "Space"
        case "tab":
            return "Tab"
        case "return", "enter":
            return "↩"
        case "escape", "esc":
            return "esc"
        case "delete", "backspace":
            return "⌫"
        case "left arrow":
            return "←"
        case "right arrow":
            return "→"
        case "up arrow":
            return "↑"
        case "down arrow":
            return "↓"
        case "left/right arrow":
            return "← →"
        case "arrow keys":
            return "←↑↓→"
        case "print screen":
            return "PrtScn"
        case "home":
            return "Home"
        case "end":
            return "End"
        default:
            // Function keys (F1 - F12).
            if lower.count <= 3, lower.hasPrefix("f"), Int(lower.dropFirst()) != nil {
                return token.uppercased()
            }
            // Single character keys: letters, digits, punctuation like ` and .
            if token.count == 1 {
                return token.uppercased()
            }
            return nil
        }
    }
}

// MARK: - Empty state

struct EmptyStateView: View {
    let title: String
    let message: String
    var systemImage: String = "magnifyingglass"

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(.tertiary)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}
