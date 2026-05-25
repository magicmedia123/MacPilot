import SwiftData
import SwiftUI

@main
struct MacPilotApp: App {
    private let modelContainer: ModelContainer

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
                .frame(minWidth: 980, minHeight: 660)
        }
        .modelContainer(modelContainer)
        .windowStyle(.titleBar)
    }
}
