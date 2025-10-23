import SwiftUI  // not just Foundation!

//class JournalViewModel: ObservableObject {
//    @Published var entries: [JournalEntry] = []
//
//    func addEntry(title: String, content: String) {
//        let new = JournalEntry(title: title, content: content, date: Date())
//        entries.insert(new, at: 0)
//    }
//
//    func deleteEntry(at offsets: IndexSet) {
//        entries.remove(atOffsets: offsets)
//    }
//
//    func toggleBookmark(for entry: JournalEntry) {
//        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
//            entries[index].isBookmarked.toggle()
//        }
//    }
//}
