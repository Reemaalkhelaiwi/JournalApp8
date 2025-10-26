import SwiftUI

struct FancyJournalSheet: View {
    @Binding var title: String
    @Binding var content: String
    var onCancel: () -> Void
    var onSave: () -> Void

    @FocusState private var focus: Field?
    private enum Field { case title, body }

    @State private var startTitle = ""
    @State private var startContent = ""
    @State private var showDiscard = false

    private let purple = Color(red: 0.58, green: 0.58, blue: 0.99)
    private let sheetGray = Color(.systemGray6)
    private let opacity: Double = 0.40

    var body: some View {
        ZStack(alignment: .top) {
            sheetGray.opacity(opacity).ignoresSafeArea()
                

            VStack(alignment: .leading, spacing: 10) {
                VStack(spacing: 10) {
                    Capsule().frame(width: 50, height: 6)
                        .foregroundStyle(.secondary).opacity(0.7)
                        .buttonStyle(.glass)
                        

                    HStack {
                        Button {
                            if isUnchanged { onCancel() } else { showDiscard = true }
                            
                        } label: {
                            ZStack {
                                Circle().fill(Color.black.opacity(0))
                                    .frame(width: 30, height: 40)
                                Image(systemName: "xmark")
                                    .font(.system(size: 25, weight: .bold))
                                    
                            }
                        }

                        Spacer()

                        Button(action: onSave) {
                            ZStack {
                                Circle().fill(purple)
                                    .buttonStyle(.glass)
                                    .frame(width: 50, height: 40)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.black.opacity(0.9))
                                      
                            }
                        }
                        .disabled(isEmpty)
                        .opacity(isEmpty ? 0.5 : 1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                HStack(alignment: .top, spacing: 10) {
                    Rectangle().fill(purple).frame(width: 3, height: 34).cornerRadius(1.5)
                    TextField("Title", text: $title)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .focused($focus, equals: .title)
                        .textInputAutocapitalization(.sentences)
                        .submitLabel(.next)
                        
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)

                Text(Date.now.formatted(date: .numeric, time: .omitted))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $content)
                        .focused($focus, equals: .body)
                        .scrollContentBackground(.hidden)
                        .background(sheetGray.opacity(opacity))
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    if content.isEmpty {
                        Text("Type your Journal...")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 22)
                            .padding(.top, 18)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(sheetGray.opacity(opacity))
                )
                .padding(.horizontal, 12)

                Spacer(minLength: 0)
            }
        }
        .alert("Are you sure you want to discard changes on this journal?",
               isPresented: $showDiscard) {
            Button("Discard Changes", role: .destructive) { onCancel() }
            Button("Keep Editing", role: .cancel) {}
        }
        .onAppear {
            startTitle = title
            startContent = content
            focus = title.isEmpty ? .title : .body
        }
    }

    private var isEmpty: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    private var isUnchanged: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines) == startTitle.trimmingCharacters(in: .whitespacesAndNewlines) &&
        content.trimmingCharacters(in: .whitespacesAndNewlines) == startContent.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    FancyJournalSheet(
        title: .constant("Test Title"),
        content: .constant("Some journal text..."),
        onCancel: {},
        onSave: {}
    )
    .preferredColorScheme(.dark)
    .buttonStyle(.glass)

}
