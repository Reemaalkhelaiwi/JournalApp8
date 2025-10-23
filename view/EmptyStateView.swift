import SwiftUI

struct EmptyStateScreen: View {
    // MARK: - Simple Model
    struct JournalEntry: Identifiable, Equatable {
        let id = UUID()
        var title: String
        var content: String
        var date: Date = .now
        var isBookmarked: Bool = false
    }

    // MARK: - State
    @State private var journals: [JournalEntry] = []
    @State private var searchText = ""
    @State private var showEditor = false
    @State private var editingIndex: Int? = nil
    @State private var draftTitle = ""
    @State private var draftContent = ""

    enum FilterMode: String { case all = "All", bookmarked = "Bookmarked", newest = "Newest First" }
    @State private var filterMode: FilterMode = .all

    // MARK: - Filtered List
    private var filteredJournals: [JournalEntry] {
        var items = journals
        switch filterMode {
        case .bookmarked: items = items.filter { $0.isBookmarked }
        case .newest: items = items.sorted { $0.date > $1.date }
        case .all: break
        }
        if !searchText.isEmpty {
            items = items.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        return items
    }

    // MARK: - UI
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if journals.isEmpty {
                    Spacer()
                    Image("emptybook")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 100)
                    Text("Begin Your Journal")
                        .font(.title3).bold()
                    Text("Tap the + to start writing your first entry.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Spacer()
                } else {
                    List {
                        ForEach(filteredJournals) { entry in
                            Button { startEditing(entry) } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(entry.title).font(.headline)
                                        if entry.isBookmarked {
                                            Image(systemName: "bookmark.fill")
                                                .foregroundColor(.purple)
                                        }
                                    }
                                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(entry.content)
                                        .lineLimit(2)
                                        .foregroundColor(.primary.opacity(0.8))
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) { delete(entry) } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button { toggleBookmark(entry) } label: {
                                    Label("Bookmark", systemImage: entry.isBookmarked ? "bookmark.slash" : "bookmark")
                                }.tint(.purple)
                            }
                        }
                    }.listStyle(.plain)
                }

                // Search Bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Search", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    Image(systemName: "mic.fill").foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(RoundedRectangle(cornerRadius: 70).fill(Color.gray.opacity(0.2)))
                .padding(.horizontal)
                .padding(.bottom, 4)
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Filter", selection: $filterMode) {
                            Text("All").tag(FilterMode.all)
                            Text("Bookmarked").tag(FilterMode.bookmarked)
                            Text("Newest First").tag(FilterMode.newest)
                        }
                    } label: {
                        Label("Sort", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { startAdding() } label: {
                        Image(systemName: "plus.circle.fill").font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                EmptyStateScreenSheet(
                    title: $draftTitle,
                    content: $draftContent,
                    onCancel: { showEditor = false },
                    onSave: { saveDraft(); showEditor = false }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .preferredColorScheme(.dark)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Actions
    private func startAdding() {
        editingIndex = nil
        draftTitle = ""
        draftContent = ""
        showEditor = true
    }

    private func startEditing(_ entry: JournalEntry) {
        if let idx = journals.firstIndex(of: entry) {
            editingIndex = idx
            draftTitle = journals[idx].title
            draftContent = journals[idx].content
            showEditor = true
        }
    }

    private func saveDraft() {
        let title = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let body  = draftContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty || !body.isEmpty else { return }

        if let idx = editingIndex {
            journals[idx].title = title.isEmpty ? "Untitled" : title
            journals[idx].content = body
            journals[idx].date = .now
        } else {
            journals.insert(.init(title: title.isEmpty ? "Untitled" : title,
                                  content: body,
                                  date: .now), at: 0)
        }
    }

    private func delete(_ entry: JournalEntry) {
        if let idx = journals.firstIndex(of: entry) {
            journals.remove(at: idx)
        }
    }

    private func toggleBookmark(_ entry: JournalEntry) {
        if let idx = journals.firstIndex(of: entry) {
            journals[idx].isBookmarked.toggle()
        }
    }
}

// MARK: - New Journal Sheet
struct EmptyStateScreenSheet: View {
    @Binding var title: String
    @Binding var content: String
    var onCancel: () -> Void
    var onSave: () -> Void

    @FocusState private var focusField: Field?
    enum Field { case title, body }
    private let purple = Color(#colorLiteral(red: 0.58, green: 0.58, blue: 0.99, alpha: 1))

    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemGray6).opacity(0.12).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                VStack(spacing: 10) {
                    Capsule().frame(width: 60, height: 5)
                        .foregroundStyle(.secondary).opacity(0.6)
                    HStack {
                        Button(action: onCancel) {
                            ZStack {
                                Circle().fill(Color.black.opacity(0.35)).frame(width: 40, height: 40)
                                Image(systemName: "xmark").font(.system(size: 16, weight: .bold))
                            }
                        }
                        Spacer()
                        Button(action: onSave) {
                            ZStack {
                                Circle().fill(purple).frame(width: 40, height: 40)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.black.opacity(0.9))
                            }
                        }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                  && content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity((title.isEmpty && content.isEmpty) ? 0.5 : 1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                HStack(alignment: .top, spacing: 10) {
                    Rectangle().fill(purple)
                        .frame(width: 3, height: 34)
                        .cornerRadius(1.5)
                    TextField("Title", text: $title)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .focused($focusField, equals: .title)
                        .textInputAutocapitalization(.sentences)
                        .submitLabel(.next)
                        .onSubmit { focusField = .body }
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)

                Text(Date.now.formatted(date: .numeric, time: .omitted))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $content)
                        .focused($focusField, equals: .body)
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                    if content.isEmpty {
                        Text("Type your Journal...")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 18)
                            .padding(.top, 16)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.18))
                )
                .padding(.horizontal, 12)
                Spacer(minLength: 0)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { focusField = title.isEmpty ? .title : .body }
    }
}

#Preview { EmptyStateScreen() }
