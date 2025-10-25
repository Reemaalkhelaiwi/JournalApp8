import SwiftUI

struct EmptyStateScreen: View {
    // Model
    struct JournalEntry: Identifiable, Equatable {
        let id = UUID()
        var title: String
        var content: String
        var date: Date = .now
        var isBookmarked: Bool = false
    }

    // State
    @State private var journals: [JournalEntry] = []
    @State private var searchText = ""
    @State private var showEditor = false
    @State private var draftTitle = ""
    @State private var draftContent = ""
    @State private var editingIndex: Int? = nil
    @State private var filterMode: FilterMode = .all

    enum FilterMode { case all, bookmarked, newest }

    private let lavender = Color(red: 0.76, green: 0.73, blue: 0.98)

    private var filteredJournals: [JournalEntry] {
        var items = journals
        switch filterMode {
        case .all: break
        case .bookmarked: items = items.filter { $0.isBookmarked }
        case .newest: items = items.sorted { $0.date > $1.date }
        }
        if !searchText.isEmpty {
            items = items.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        return items
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 16) {
                HStack {
                    Text("Journal")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Spacer()
                    HStack(spacing: 12) {
                        Menu {
                           
                            Button("sort by bookmark")   { filterMode = .bookmarked }
                            Button("sort by entry date") { filterMode = .newest }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                        Button { startAdding() } label: {
                            Image(systemName: "plus")
                        }
                    }
                    .font(.title3)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
                .padding(.horizontal)

                if filteredJournals.isEmpty {
                    Spacer()
                    Image("emptybook")
                        .resizable().scaledToFit()
                        .frame(width: 180, height: 100)
                    Text("Begin Your Journal").font(.title3).bold()
                    Text("Tap the + to start writing your first entry.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 18) {
                            ForEach(filteredJournals) { entry in
                                journalCard(entry)
                                    .onTapGesture { startEditing(entry) }
                                    .contextMenu {
                                        Button(entry.isBookmarked ? "Remove Bookmark" : "Bookmark") {
                                            toggleBookmark(entry)
                                        }
                                        Button("Delete", role: .destructive) {
                                            delete(entry)
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 80)
                    }
                }
            }

            // Floating search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField("Search", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                Image(systemName: "mic.fill").foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(radius: 6, y: 2)
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showEditor) {
            FancyJournalSheet(
                title: $draftTitle,
                content: $draftContent,
                onCancel: { showEditor = false },
                onSave:  { saveDraft(); showEditor = false }
            )
            .preferredColorScheme(.dark)
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
    }

    private func journalCard(_ entry: JournalEntry) -> some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.secondarySystemBackground).opacity(0.35))
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    Text(entry.title)
                        .foregroundColor(lavender)
                        .font(.system(size: 22, weight: .semibold))
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: entry.isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(lavender)
                        .onTapGesture { toggleBookmark(entry) }
                }
                Text(entry.date.formatted(date: .numeric, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(entry.content)
                    .foregroundColor(.primary.opacity(0.92))
                  
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func startAdding() {
        editingIndex = nil
        draftTitle = ""
        draftContent = ""
        showEditor = true
    }

    private func startEditing(_ entry: JournalEntry) {
        if let i = journals.firstIndex(of: entry) {
            editingIndex = i
            draftTitle = journals[i].title
            draftContent = journals[i].content
            showEditor = true
        }
    }

    private func saveDraft() {
        let t = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let c = draftContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty || !c.isEmpty else { return }

        if let i = editingIndex {
            journals[i].title = t.isEmpty ? "Untitled" : t
            journals[i].content = c
            journals[i].date = .now
        } else {
            journals.insert(.init(title: t.isEmpty ? "Untitled" : t, content: c, date: .now), at: 0)
        }
    }

    private func delete(_ entry: JournalEntry) {
        if let i = journals.firstIndex(of: entry) {
            journals.remove(at: i)
        }
    }

    private func toggleBookmark(_ entry: JournalEntry) {
        if let i = journals.firstIndex(of: entry) {
            journals[i].isBookmarked.toggle()
        }
    }
}

#Preview {
    EmptyStateScreen()
        .preferredColorScheme(.dark)
}
