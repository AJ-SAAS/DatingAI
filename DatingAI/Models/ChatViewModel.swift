import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    
    private let apiKey = "YOUR_OPENAI_API_KEY"

    func sendMessage() {
        let userMessage = ChatMessage(text: currentInput, isFromUser: true)
        messages.append(userMessage)

        // Clear input
        currentInput = ""

        callOpenAIAPI(for: userMessage.text)
    }

    private func callOpenAIAPI(for input: String) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }

        let payload: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful dating coach AI."],
                ["role": "user", "content": input]
            ],
            "temperature": 0.7
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("Error encoding request body: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("OpenAI API Error: \(error)")
                return
            }

            guard let data = data else { return }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: String],
                   let content = message["content"] {

                    DispatchQueue.main.async {
                        let aiMessage = ChatMessage(text: content.trimmingCharacters(in: .whitespacesAndNewlines), isFromUser: false)
                        self?.messages.append(aiMessage)
                    }
                }
            } catch {
                print("Failed to decode OpenAI response: \(error)")
            }
        }.resume()
    }
}
