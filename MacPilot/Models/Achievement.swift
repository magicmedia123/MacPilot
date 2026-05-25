import Foundation
import SwiftData

@Model
final class Achievement {
    @Attribute(.unique) var id: String
    var title: String
    var detail: String
    var symbolName: String
    var isUnlocked: Bool
    var unlockedAt: Date?

    init(
        id: String,
        title: String,
        detail: String,
        symbolName: String,
        isUnlocked: Bool = false,
        unlockedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.symbolName = symbolName
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
    }
}
