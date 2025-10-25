import SwiftUI

struct EmptyStateScreen: View {
    // MARK: State
    @State private var journals: [JournalEntry] = []
    @State private var searchText = ""
    @State private var showEditor = false
    @State private var draftTitle = ""
    @State private var draftContent = ""
    @State private var editingIndex: Int? = nil
    @State private var filter: Filter = .all

    // delete confirmation
    @State private var pendingDelete: JournalEntry? = nil
    @State private var showDeleteAlert = false

    enum Filter { case all, bookmarked, newest }

    // MARK: Style
    private let lavender = Color(red: 0.76, green: 0.73, blue: 0.98)
    private let surface  = Color(red: 0.12, green: 0.12, blue: 0.12) // same gray everywhere

    // MARK: Derived
    private var items: [JournalEntry] {
        var r = journals
        if filter == .bookmarked { r = r.filter { $0.isBookmarked } }
        if filter == .newest     { r = r.sorted { $0.date > $1.date } }
        if !searchText.isEmpty {
            r = r.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        return r
    }

    // MARK: View
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 16) {
                header

                if items.isEmpty {
                    emptyView
                } else {
                    // Use List so swipeActions work, but keep the card look
                    List {
                        ForEach(items) { entry in
                            card(for: entry)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        pendingDelete = entry
                                        showDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        toggleBookmark(entry)
                                    } label: {
                                        Label(entry.isBookmarked ? "Unbookmark" : "Bookmark",
                                              systemImage: entry.isBookmarked ? "bookmark.slash" : "bookmark")
                                    }
                                    .tint(.purple)
                                }
                                .onTapGesture { beginEdit(entry) }
                        }
                    }
                    .listStyle(.plain)
                    .animation(.default, value: journals)
                    .padding(.horizontal, 4) // tiny inset to match your spacing
                    .padding(.bottom, 60)    // room for the floating search
                }
            }

            searchBar
        }
        .preferredColorScheme(.dark)
        // Delete confirmation alert
        .alert("Delete Journal?", isPresented: $showDeleteAlert, presenting: pendingDelete) { entry in
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { delete(entry) }
        } message: { _ in
            Text("Are you sure you want to delete this journal?")
        }
        // Editor sheet (your fancy sheet)
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

    // MARK: Pieces
    private var header: some View {
        HStack {
            Text("Journal")
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Spacer()
            HStack(spacing: 12) {
                Menu {
                    Button("sort by bookmark")   { filter = .bookmarked }
                    Button("sort by entry date") { filter = .newest }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
                Button { beginAdd() } label: { Image(systemName: "plus") }
            }
            .font(.title3)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
        .padding(.horizontal)
    }

    private var emptyView: some View {
        VStack {
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
        }
    }

    private func card(for e: JournalEntry) -> some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 22).fill(surface)
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    Text(e.title)
                        .foregroundColor(lavender)
                        .font(.system(size: 22, weight: .semibold))
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: e.isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(lavender)
                        .onTapGesture { toggleBookmark(e) }
                }
                Text(e.date.formatted(date: .numeric, time: .omitted))
                    .font(.caption).foregroundColor(.secondary)
                Text(e.content).foregroundColor(.primary.opacity(0.92))
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle()) // makes the whole card tappable / swipable
    }

    private var searchBar: some View {
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
        .background(surface)
        .clipShape(Capsule())
        .padding(.horizontal)
        .padding(.bottom, 16)
    }

    // MARK: Actions
    private func beginAdd() {
        editingIndex = nil
        draftTitle = ""
        draftContent = ""
        showEditor = true
    }

    private func beginEdit(_ e: JournalEntry) {
        if let i = journals.firstIndex(of: e) {
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

    private func delete(_ e: JournalEntry) {
        if let i = journals.firstIndex(of: e) { journals.remove(at: i) }
    }

    private func toggleBookmark(_ e: JournalEntry) {
        if let i = journals.firstIndex(of: e) { journals[i].isBookmarked.toggle() }
    }
}

#Preview {
    EmptyStateScreen().preferredColorScheme(.dark)
}
