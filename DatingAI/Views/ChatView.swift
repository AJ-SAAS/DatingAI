import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isTextFieldFocused: Bool // Track TextField focus

    var body: some View {
        VStack {
            // Top bar with Olivia's name, online status, and profile picture, centered
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    Text("Olivia")
                        .font(.headline)
                        .foregroundColor(.white)
                    HStack(spacing: 8) {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.green)
                        Text("Online")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                Spacer()
                Image("oliviaimage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.black)

            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            HStack(alignment: .top, spacing: 8) {
                                if message.isFromUser {
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(message.text)
                                            .padding()
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(10)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: 250, alignment: .trailing)
                                        Text(formatTimestamp(message.timestamp))
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.6))
                                            .padding(.trailing, 8)
                                    }
                                } else {
                                    Image("oliviaimage")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(message.text)
                                            .padding()
                                            .background(Color.purple.opacity(0.3))
                                            .cornerRadius(10)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: 250, alignment: .leading)
                                        Text(formatTimestamp(message.timestamp))
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.6))
                                            .padding(.leading, 8)
                                    }
                                    Spacer()
                                }
                            }
                            .id(message.id)
                        }

                        // Typing indicator when Olivia is "typing"
                        if viewModel.isLoading {
                            HStack(alignment: .top, spacing: 8) {
                                Image("oliviaimage")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                TypingIndicator()
                                    .frame(maxWidth: 250, alignment: .leading)
                                Spacer()
                            }
                            .id("typingIndicator")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation {
                        scrollViewProxy.scrollTo(viewModel.messages.last?.id ?? "typingIndicator", anchor: .bottom)
                    }
                }
                .onChange(of: viewModel.isLoading) { isLoading in
                    if isLoading {
                        withAnimation {
                            scrollViewProxy.scrollTo("typingIndicator", anchor: .bottom)
                        }
                    }
                }
                // Dismiss keyboard on tap outside TextField
                .onTapGesture {
                    isTextFieldFocused = false
                }
            }

            Divider()
                .background(Color.white.opacity(0.3))

            HStack(alignment: .center, spacing: 8) {
                TextField("", text: $viewModel.currentInput, prompt: Text("What's on your mind..?").foregroundColor(.gray.opacity(0.7)))
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .foregroundColor(.white)
                    .frame(minHeight: 48)
                    .padding(.horizontal)
                    .focused($isTextFieldFocused) // Bind focus state

                Button(action: {
                    viewModel.sendMessage()
                    isTextFieldFocused = false // Dismiss keyboard after sending
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .frame(width: 48, height: 48)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.black)
        }
        .navigationTitle("")
        .background(Color.black.ignoresSafeArea())
    }

    // Format timestamp for display
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Typing indicator view with animated dots
struct TypingIndicator: View {
    @State private var dotOpacity1: Double = 0.3
    @State private var dotOpacity2: Double = 0.3
    @State private var dotOpacity3: Double = 0.3

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(.white)
                .opacity(dotOpacity1)
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(.white)
                .opacity(dotOpacity2)
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(.white)
                .opacity(dotOpacity3)
        }
        .padding()
        .background(Color.purple.opacity(0.3))
        .cornerRadius(10)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.0)) {
                dotOpacity1 = 1.0
            }
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.2)) {
                dotOpacity2 = 1.0
            }
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.4)) {
                dotOpacity3 = 1.0
            }
        }
    }
}

// Extension to add placeholder functionality (optional, kept for reference)
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview("iPhone 14") {
    ChatView()
}

#Preview("iPad Pro") {
    ChatView()
}
