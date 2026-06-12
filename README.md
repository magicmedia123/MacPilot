# MacPilot

MacPilot is a native macOS SwiftUI app that helps Windows users learn Mac keyboard shortcuts and trackpad gestures through short daily lessons, spaced-repetition reviews, and a quick-reference cheat sheet.

## Features

- **27 hands-on lessons** across four categories: Keyboard Shortcuts, Touchpad Gestures, Mac Navigation, and Productivity — each pairing the Windows habit with its Mac equivalent, rendered as realistic keycaps.
- **Live keyboard practice**: lessons with a practicable shortcut listen for the real key combo (safely swallowing things like ⌘W while you practice); other lessons use a quick quiz check.
- **Shortcut Cheat Sheet**: every Windows → Mac mapping in one searchable, filterable reference. Click a row to open its lesson, right-click to copy the shortcut.
- **Personalized recommendations**: onboarding asks about your experience, Windows apps, and goals, and the Home screen's "Up Next" card explains why each lesson was picked.
- **Spaced repetition**: completed lessons enter an SM-2 style review schedule; due reviews surface on the Home screen.
- **Streaks, achievements, and progress tracking** with a 7-day activity strip and per-category breakdowns.
- **⌘1–⌘6 navigation** via the Go menu — a shortcuts app you can drive with shortcuts.
- **Appearance setting** (System / Light / Dark) and a full local-data reset.

## Project Structure

- `MacPilot.xcodeproj` — Xcode project for the macOS app.
- `MacPilot/MacPilotApp.swift` — App entry point, SwiftData container, menu commands, appearance.
- `MacPilot/ContentView.swift` — Sidebar navigation, app router (deep links between screens), branding.
- `MacPilot/Models` — SwiftData models: lessons, lesson steps, user progress, achievements, review items.
- `MacPilot/ViewModels` — Screen-focused view models (dashboard recommendations, lesson filtering, progress, settings).
- `MacPilot/Services` — Lesson catalog, first-launch seeding/migration, achievement unlock logic.
- `MacPilot/Views/Home` — Dashboard with hero stats, Up Next card, and review card.
- `MacPilot/Views/Lessons` — Lesson list (category sections, filters) and detail (steps, practice, completion).
- `MacPilot/Views/CheatSheet` — The Windows → Mac shortcut reference.
- `MacPilot/Views/Progress` — Progress, streak, and category breakdown dashboard.
- `MacPilot/Views/Achievements` — Badge grid with unlock progress hints.
- `MacPilot/Views/Settings` — Appearance and local learning data controls.
- `MacPilot/Views/Onboarding` — Animated multi-step onboarding flow.
- `MacPilot/Views/Shared` — Design system (keycaps, icon tiles, chips, cards, rings, confetti).

## Notes

- Storage is local-only through SwiftData; nothing leaves the Mac.
- The lesson catalog is seeded on first launch; subsequent launches migrate metadata and add new lessons without touching user progress.
- Targets the latest macOS SDK and uses system colors/materials for full dark-mode support.
