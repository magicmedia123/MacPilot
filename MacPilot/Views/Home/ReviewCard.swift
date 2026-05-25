import SwiftData
import SwiftUI

struct ReviewCard: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var reviewItems: [ReviewItem]
    @Query private var lessons: [Lesson]
    
    @State private var showingReviewSession = false
    
    private var dueItems: [ReviewItem] {
        let today = Calendar.current.startOfDay(for: .now)
        // Item is due if nextReviewDate is today or earlier
        return reviewItems.filter { item in
            Calendar.current.startOfDay(for: item.nextReviewDate) <= today
        }
    }
    
    var body: some View {
        CardView {
            HStack(alignment: .top, spacing: 18) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(dueItems.isEmpty ? Color.secondary : Color.accentColor)
                    .frame(width: 56, height: 56)
                    .background((dueItems.isEmpty ? Color.gray : Color.accentColor).opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Spaced Repetition Review")
                        .font(.headline)
                    
                    if dueItems.isEmpty {
                        Text("All caught up!")
                            .font(.title2.weight(.semibold))
                        
                        Text("You have reviewed all completed shortcuts. New reviews will be scheduled automatically.")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(dueItems.count) due for review")
                            .font(.title2.weight(.semibold))
                        
                        Text("Practice your completed shortcuts to build strong muscle memory.")
                            .foregroundStyle(.secondary)
                        
                        Button {
                            showingReviewSession = true
                        } label: {
                            Label("Start Review Session", systemImage: "play.fill")
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                    }
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingReviewSession) {
            ReviewSessionView(dueItems: dueItems, lessons: lessons)
                .frame(width: 500, height: 400)
        }
    }
}

struct ReviewSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let dueItems: [ReviewItem]
    let lessons: [Lesson]
    
    @State private var currentIndex = 0
    @State private var revealAnswer = false
    @State private var showsCelebration = false
    
    private var currentItem: ReviewItem? {
        guard currentIndex < dueItems.count else { return nil }
        return dueItems[currentIndex]
    }
    
    private var currentLesson: Lesson? {
        guard let item = currentItem else { return nil }
        return lessons.first(where: { $0.id == item.lessonId })
    }
    
    var body: some View {
        VStack {
            if showsCelebration {
                celebrationView
            } else if let lesson = currentLesson, let item = currentItem {
                sessionProgress
                
                Spacer()
                
                lessonCard(lesson: lesson)
                
                Spacer()
                
                if revealAnswer {
                    actionButtons(item: item)
                } else {
                    Button {
                        withAnimation { revealAnswer = true }
                    } label: {
                        Text("Reveal Mac Action")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                }
            } else {
                noItemsView
            }
        }
        .padding(32)
        .overlay {
            if showsCelebration {
                ConfettiView(isActive: $showsCelebration)
            }
        }
    }
    
    private var sessionProgress: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Review Session")
                    .font(.headline)
                Spacer()
                Text("\(currentIndex + 1) of \(dueItems.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: Double(currentIndex), total: Double(dueItems.count))
                .tint(Color.accentColor)
        }
    }
    
    private func lessonCard(lesson: Lesson) -> some View {
        VStack(spacing: 20) {
            Image(systemName: lesson.symbolName)
                .font(.system(size: 48))
                .foregroundStyle(Color.accentColor)
            
            VStack(spacing: 8) {
                Text("Habit to replace (Windows)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                
                // Show windows equivalent of first step
                Text(lesson.steps.first?.windowsEquivalent ?? "Equivalent action")
                    .font(.title2.weight(.semibold))
                    .strikethrough()
                    .foregroundStyle(.secondary)
            }
            
            if revealAnswer {
                VStack(spacing: 8) {
                    Text("Mac Action")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.accentColor)
                    
                    Text(lesson.steps.first?.macAction ?? "Mac equivalent")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.primary)
                        .scaleEffect(revealAnswer ? 1.05 : 1.0)
                        .animation(.spring(duration: 0.4), value: revealAnswer)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Text("Press 'Reveal' to check if you remember the Mac equivalent.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
        )
    }
    
    private func actionButtons(item: ReviewItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How well did you recall this?")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack(spacing: 8) {
                // Forgot (Quality 1)
                recallButton(title: "Forgot 🔴", quality: 1, item: item)
                
                // Hard (Quality 3)
                recallButton(title: "Hard 🟡", quality: 3, item: item)
                
                // Good (Quality 4)
                recallButton(title: "Good 🟢", quality: 4, item: item)
                
                // Easy (Quality 5)
                recallButton(title: "Easy 🔵", quality: 5, item: item)
            }
        }
    }
    
    private func recallButton(title: String, quality: Int, item: ReviewItem) -> some View {
        Button {
            item.updateRecall(quality: quality)
            try? modelContext.save()
            
            if currentIndex + 1 < dueItems.count {
                withAnimation {
                    revealAnswer = false
                    currentIndex += 1
                }
            } else {
                withAnimation {
                    showsCelebration = true
                }
            }
        } label: {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
        }
        .buttonStyle(BorderedButtonStyle())
    }
    
    private var celebrationView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            
            VStack(spacing: 8) {
                Text("Review Session Complete!")
                    .font(.title.weight(.bold))
                
                Text("Great job! You reviewed \(dueItems.count) shortcuts. Spaced repetition has rescheduled these based on your recall quality.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Close")
                    .frame(width: 120)
            }
            .buttonStyle(BorderedProminentButtonStyle())
        }
    }
    
    private var noItemsView: some View {
        VStack(spacing: 16) {
            Text("No items due for review.")
                .font(.headline)
            
            Button("Dismiss") {
                dismiss()
            }
            .buttonStyle(BorderedButtonStyle())
        }
    }
}
