import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 8) {
            List(viewModel.messages, id: \.self) { msg in
                Text(msg)
            }
            HStack {
                TextField("Message", text: $viewModel.input)
                    .textFieldStyle(.roundedBorder)
                Button(viewModel.isSending ? "…" : "Send") { viewModel.send() }
                    .disabled(viewModel.isSending || viewModel.input.isEmpty)
            }
        }
        .padding()
        .navigationTitle("Chat")
        .onDisappear { viewModel.stop() }
    }
}
