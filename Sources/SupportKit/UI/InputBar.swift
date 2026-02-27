import SwiftUI

/// Text input bar for composing messages
struct InputBar: View {
    @Binding var text: String
    let isProcessing: Bool
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .disabled(isProcessing)
                .onSubmit(onSend)

            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(canSend ? Color.accentColor : Color.secondary)
            }
            .disabled(!canSend)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(white: 1.0).opacity(0.95))
        .overlay(alignment: .top) {
            Divider()
        }
    }

    private var canSend: Bool {
        !isProcessing && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    VStack {
        Spacer()
        InputBar(text: .constant("Hello"), isProcessing: false, onSend: {})
        InputBar(text: .constant(""), isProcessing: true, onSend: {})
    }
}
