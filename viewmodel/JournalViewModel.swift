import Foundation
import Combine

@MainActor
final class JournalViewModel: ObservableObject {
    // MARK: - State
    @Published var journals: [JournalEntry] = []
    @Published var searchText: String = ""
    @Published var filter: Filter = .all
    @Published  var showDeleteAlert = false

    enum Filter { case all, bookmarked, newest }

    // MARK: - Derived list
    var items: [JournalEntry] {
        var r = journals
        switch filter {
        case .all: break
        case .bookmarked: r = r.filter { $0.isBookmarked }
        case .newest: r = r.sorted { $0.date > $1.date }
        }
        if !searchText.isEmpty {
            r = r.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        return r
    }

    // MARK: - Actions
    func upsert(editingIndex: Int?, title: String, content: String) {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let c = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty || !c.isEmpty else { return }

        if let i = editingIndex {
            journals[i].title = t.isEmpty ? "Untitled" : t
            journals[i].content = c
            journals[i].date = .now
        } else {
            journals.insert(.init(title: t.isEmpty ? "Untitled" : t, content: c), at: 0)
        }
    }

    func delete(_ entry: JournalEntry) {
        if let i = journals.firstIndex(of: entry) { journals.remove(at: i) }
    }

    func toggleBookmark(_ entry: JournalEntry) {
        if let i = journals.firstIndex(of: entry) {
            journals[i].isBookmarked.toggle()
        }
    }
    // Add this inside your JournalViewModel class
    private var pendingDelete: JournalEntry?

    func requestDelete(_ entry: JournalEntry) {
        pendingDelete = entry
    }

    func confirmDelete() {
        guard let entry = pendingDelete else { return }
        if let i = journals.firstIndex(of: entry) {
            journals.remove(at: i)
        }
        pendingDelete = nil
    }
}
