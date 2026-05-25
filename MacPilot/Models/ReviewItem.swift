import Foundation
import SwiftData

@Model
final class ReviewItem {
    @Attribute(.unique) var id: String
    var lessonId: String
    var nextReviewDate: Date
    var easeFactor: Double
    var interval: Int
    var repetitions: Int
    var lastReviewedAt: Date?

    init(
        lessonId: String,
        nextReviewDate: Date = .now,
        easeFactor: Double = 2.5,
        interval: Int = 0,
        repetitions: Int = 0,
        lastReviewedAt: Date? = nil
    ) {
        self.id = "review-\(lessonId)"
        self.lessonId = lessonId
        self.nextReviewDate = nextReviewDate
        self.easeFactor = easeFactor
        self.interval = interval
        self.repetitions = repetitions
        self.lastReviewedAt = lastReviewedAt
    }

    func updateRecall(quality: Int) {
        let now = Date.now
        lastReviewedAt = now
        
        if quality >= 3 {
            if repetitions == 0 {
                interval = 1
            } else if repetitions == 1 {
                interval = 6
            } else {
                interval = Int(ceil(Double(interval) * easeFactor))
            }
            repetitions += 1
        } else {
            repetitions = 0
            interval = 1
        }
        
        let q = Double(quality)
        let easeFactorCorrection = 0.1 - (5.0 - q) * (0.08 + (5.0 - q) * 0.02)
        easeFactor = max(1.3, easeFactor + easeFactorCorrection)
        
        nextReviewDate = Calendar.current.date(byAdding: .day, value: interval, to: now) ?? now
    }
}
