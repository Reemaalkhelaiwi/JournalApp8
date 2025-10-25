import SwiftUI

struct EmptyStateScreen: View {
    @StateObject private var vm = JournalViewModel()

    @State private var showEditor = false
    @State private var draftTitle = ""
    @State private var draftContent = ""
    @State private var editingIndex: Int? = nil

    @State private var pendingDelete: JournalEntry? = nil
    @State private var showDeleteAlert = false

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
                        ForEach(vm.items) { entry in
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
                                        vm.toggleBookmark(entry)
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
                    .animation(.default, value: vm.journals)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 60)
                }
            }

            searchBar
        }
        .preferredColorScheme(.dark)
        .alert("Delete Journal?", isPresented: $showDeleteAlert, presenting: pendingDelete) { entry in
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { vm.delete(entry) }
        } message: { _ in
            Text("Are you sure you want to delete this journal?")
        }
        .sheet(isPresented: $showEditor) {
            FancyJournalSheet(
                title: $draftTitle,
                content: $draftContent,
                onCancel: { showEditor = false },
                onSave:  { vm.upsert(editingIndex: editingIndex, title: draftTitle, content: draftContent)
                           showEditor = false }
            )
            .preferredColorScheme(.dark)
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
    }

    private var header: some View {
        HStack {
            Text("Journal")
                .font(.system(size: 34, weight: .bold, design: .rounded))
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
                        .onTapGesture { vm.toggleBookmark(e) }
                }
                Text(e.date.formatted(date: .numeric, time: .omitted))
                    .font(.caption).foregroundColor(.secondary)
                Text(e.content).foregroundColor(.primary.opacity(0.92))
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

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
        .background(surface)
        .clipShape(Capsule())
        .padding(.horizontal)
        .padding(.bottom, 16)
    }

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
    EmptyStateScreen()
        .preferredColorScheme(.dark)
}
