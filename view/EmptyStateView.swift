
import SwiftUI
struct EmptyStateView: View   {
    @StateObject private var vm = JournalViewModel()

    @State private var showEditor = false
    @State private var draftTitle = ""
    @State private var draftContent = ""
    @State private var editingIndex: Int? = nil

    // 🛠 Drive the confirm dialog from this optional item
    @State private var pendingDelete: JournalEntry? = nil

    private let lavender = Color(red: 0.76, green: 0.73, blue: 0.98)
    private let surface  = Color(red: 0.12, green: 0.12, blue: 0.12)

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 16) {
                header

                if vm.items.isEmpty {
                    emptyView
                } else {
                    List {
                        // ⬇️ delete-related area
                        ForEach(vm.items) { entry in
                            card(for: entry)
                                .contentShape(Rectangle()) // easier swipe/tap target
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        // trigger confirm dialog
                                        pendingDelete = entry
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        vm.toggleBookmark(entry)
                                    } label: {
                                        Label(entry.isBookmarked ? "Unbookmark" : "Bookmark",
                                              systemImage: entry.isBookmarked ? "bookmark.slash" : "bookmark")
                                    }
                                    .tint(.purple)
                                }
                                .onTapGesture { beginEdit(entry) }
                        }
                        // Native delete support (also works in Edit mode)
                        .onDelete { indexSet in
                            for index in indexSet {
                                let id = vm.items[index].id
                                if let i = vm.journals.firstIndex(where: { $0.id == id }) {
                                    vm.journals.remove(at: i)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .animation(.default, value: vm.journals)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 60)
                    // 🔔 Attach the confirmation to the List so it shows reliably
                    .confirmationDialog(
                        "Delete Journal?",
                        isPresented: Binding(
                            get: { pendingDelete != nil },
                            set: { if !$0 { pendingDelete = nil } }
                        ),
                        presenting: pendingDelete
                    ) { entry in
                        Button("Delete", role: .destructive) {
                            vm.delete(entry)
                            pendingDelete = nil
                        }
                        Button("Cancel", role: .cancel) {
                            pendingDelete = nil
                        }
                    } message: { entry in
                        Text("Are you sure you want to delete “\(entry.title)”?")
                           
                    }
                    
                }
            }

            searchBar
        }
        .preferredColorScheme(.dark)

        // Editor sheet
        .sheet(isPresented: $showEditor) {
            FancyJournalSheet(
                title: $draftTitle,
                content: $draftContent,
                onCancel: { showEditor = false },
                onSave:  {
                    vm.upsert(editingIndex: editingIndex, title: draftTitle, content: draftContent)
                    showEditor = false
                }
            )
            .preferredColorScheme(.dark)
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
    }

    // MARK: Header
    private var header: some View {
        HStack {
            Text("Journal")
                .font(.system(size: 45, weight: .bold, design: .default))
            Spacer()
            HStack(spacing: 12) {
                Menu {
                    Button("sort by bookmark")   { vm.filter = .bookmarked }
                    Button("sort by entry date") { vm.filter = .newest }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
                Button { beginAdd() } label: { Image(systemName: "plus") }
            }
            .font(.title3)
            .padding(.vertical,8)
            .padding(.horizontal, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .buttonStyle(.glass)
        }
        .padding(.horizontal)
    }

    // MARK: Empty view
    private var emptyView: some View {
        VStack {
            Spacer()
            Image("emptybook")
                .resizable().scaledToFit()
                .frame(width: 200, height: 150)
            Text("Begin Your Journal")
                .font(.title3).bold()
                .foregroundColor(lavender)
            Text("Craft your personal diary, tap the plus icon to begin")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }

    // MARK: Card
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
                        .onTapGesture { vm.toggleBookmark(e) }
                }
                Text(e.date.formatted(date: .numeric, time: .omitted))
                    .font(.caption).foregroundColor(.secondary)
                Text(e.content).foregroundColor(.primary.opacity(1))
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

    // MARK: Search bar
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundColor(.secondary)
            TextField("Search", text: $vm.searchText)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .submitLabel(.search)
            Image(systemName: "mic.fill").foregroundColor(.secondary)
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .padding(.horizontal)
        .padding(.bottom, 16)
    }

    // MARK: Editing helpers
    private func beginAdd() {
        editingIndex = nil
        draftTitle = ""
        draftContent = ""
        showEditor = true
    }

    private func beginEdit(_ e: JournalEntry) {
        if let i = vm.journals.firstIndex(of: e) {
            editingIndex = i
            draftTitle = vm.journals[i].title
            draftContent = vm.journals[i].content
            showEditor = true
        }
    }
}

#Preview {
    EmptyStateView()
        .preferredColorScheme(.dark)
}
