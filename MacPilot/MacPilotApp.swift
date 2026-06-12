import SwiftData
import SwiftUI

@main
struct MacPilotApp: App {
    private let modelContainer: ModelContainer

    @AppStorage("appearanceMode") private var appearanceMode = AppearanceMode.system

    init() {
        do {
            let schema = Schema([
                Lesson.self,
                LessonStep.self,
                UserProgress.self,
                Achievement.self,
                ReviewItem.self
            ])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1000, minHeight: 680)
                .preferredColorScheme(appearanceMode.colorScheme)
        }
        .modelContainer(modelContainer)
        .windowStyle(.titleBar)
        .commands {
            // A shortcuts-learning app should itself be driveable by shortcuts.
            CommandMenu("Go") {
                ForEach(SidebarItem.allCases) { item in
                    Button(item.title) {
                        AppRouter.shared.selection = item
                    }
                    .keyboardShortcut(item.keyEquivalent, modifiers: .command)
                }
            }
        }
    }
}
