import Foundation

struct JournalEntry: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var content: String
    var date: Date = .now
    var isBookmarked: Bool = false
}
