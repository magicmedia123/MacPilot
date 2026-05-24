# MacPilot

MacPilot is a native macOS SwiftUI app that helps Windows users learn Mac keyboard shortcuts and touchpad gestures.

## Project Structure

- `MacPilot.xcodeproj`: Xcode project for the macOS app.
- `MacPilot/MacPilotApp.swift`: App entry point and SwiftData container setup.
- `MacPilot/ContentView.swift`: Sidebar navigation architecture.
- `MacPilot/Models`: SwiftData models for lessons, lesson steps, and user progress.
- `MacPilot/ViewModels`: Screen-focused view models for dashboard, lessons, progress, and settings logic.
- `MacPilot/Services`: Mock lesson data and first-launch seeding.
- `MacPilot/Views/Home`: Dashboard/home screen.
- `MacPilot/Views/Lessons`: Lesson list and detail screens.
- `MacPilot/Views/Progress`: Progress and streak dashboard.
- `MacPilot/Views/Settings`: Local learning data controls.
- `MacPilot/Views/Onboarding`: Beginner onboarding flow.
- `MacPilot/Views/Shared`: Reusable Apple-style card and metric views.

## Notes

- Storage is local-only through SwiftData.
- Mock lesson data is inserted on first launch, then persisted locally.
- The app targets the latest macOS SDK and uses system colors/materials for dark mode support.
