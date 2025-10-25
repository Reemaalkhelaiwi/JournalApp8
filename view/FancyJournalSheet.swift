import SwiftUI

struct FancyJournalSheet: View {
    @Binding var title: String
    @Binding var content: String
    var onCancel: () -> Void
    var onSave: () -> Void

    @FocusState private var focus: Field?
    private enum Field { case title, body }

    // ONE shade used everywhere
    // ONE shade used everywhere
    private let purple = Color(red: 0.58, green: 0.58, blue: 0.99)
    private let sheetGray = Color(red: 0.12, green: 0.12, blue: 0.12) // neutral custom gray
    private let opacity: Double = 1.0
    
    var body: some View {
        ZStack(alignment: .top) {
            sheetGray.opacity(opacity).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 10) {
                // Handle + controls
                VStack(spacing: 10) {
                    Capsule()
                        .frame(width: 45, height: 5)
                        .foregroundStyle(.secondary).opacity(0.6)

                    HStack {
                        circleButton(system: "xmark",
                                     fill: Color.black.opacity(0.35),
                                     action: onCancel)
                        Spacer()
                        circleButton(system: "checkmark",
                                     fill: purple,
                                     fg: .black.opacity(0.9),
                                     action: onSave)
                        .disabled(isEmpty)
                        .opacity(isEmpty ? 0.5 : 1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Title with accent
                HStack(alignment: .top, spacing: 10) {
                    Rectangle().fill(purple)
                        .frame(width: 3, height: 34)
                        .cornerRadius(1.5)

                    TextField("Title", text: $title)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .focused($focus, equals: .title)
                        .textInputAutocapitalization(.sentences)
                        .submitLabel(.next)
                        .onSubmit { focus = .body }
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)

                Text(Date.now.formatted(date: .numeric, time: .omitted))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)

                // Body (single gray, same as sheet)
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $content)
                        .focused($focus, equals: .body)
                        .scrollContentBackground(.hidden)        // remove default dark layer
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(sheetGray.opacity(opacity))  // EXACT same shade
                        )

                    if content.isEmpty {
                        Text("Type your Journal...")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.top, 18)
                    }
                }
                .padding(.horizontal, 12)

                Spacer(minLength: 0)
            }
        }
        .onAppear { focus = title.isEmpty ? .title : .body }
        .preferredColorScheme(.dark)
    }

    private var isEmpty: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func circleButton(system: String,
                              fill: Color,
                              fg: Color = .primary,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle().fill(fill).frame(width: 40, height: 40)
                Image(systemName: system)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(fg)
            }
        }
    }
}

#Preview {
    FancyJournalSheet(title: .constant(""),
                      content: .constant(""),
                      onCancel: {},
                      onSave: {})
        .preferredColorScheme(.dark)
}
