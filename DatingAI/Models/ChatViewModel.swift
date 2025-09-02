import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var isLoading: Bool = false
    
    private let db = Firestore.firestore()
    private let userID: String
    private let apiKey: String
    
    init() {
        guard let filePath = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let apiKey = plist["OpenAI_API_Key"] as? String else {
            fatalError("Couldn't find or read OpenAI_API_Key in Config.plist")
        }
        self.apiKey = apiKey
        
        guard let userID = Auth.auth().currentUser?.uid else {
            fatalError("User not authenticated")
        }
        self.userID = userID
        
        // Load initial welcome message
        let welcomeMessage = ChatMessage(
            text: "Hey there! I'm Olivia, your dating coach. 😊 Tell me what's up—like if you're on a date and the convo's gone cold—and I'll give you step-by-step tips to make it spark!",
            isFromUser: false,
            timestamp: Date()
        )
        messages.append(welcomeMessage)
        saveMessageToFirestore(welcomeMessage)
        
        // Load messages from Firestore
        loadMessagesFromFirestore()
    }
    
    func sendMessage() {
        let userMessage = ChatMessage(text: currentInput, isFromUser: true)
        messages.append(userMessage)
        saveMessageToFirestore(userMessage)
        
        currentInput = ""
        isLoading = true
        
        Task {
            await callOpenAIAPI(for: userMessage.text)
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    private func callOpenAIAPI(for input: String) async {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }
        
        let systemPrompt = """
        You are Olivia, a dating coach AI modeled after Olivia Alexa, a YouTuber with 400,000+ subscribers who helps men improve their dating lives. Your tone is warm, witty, encouraging, and slightly flirty, like a supportive winggirl. Provide practical, step-by-step advice for men in real-time dating scenarios (e.g., conversation going cold). Use specific examples, like suggesting questions or topics (e.g., 'Ask about her favorite travel story'). Avoid vague advice and focus on actionable steps that feel natural. If the user describes a situation, tailor the response. Incorporate emotional intelligence and modern dating tips, and end with an encouraging message like 'You've got this!' Return responses in this JSON format:
        {
          "steps": [
            {"step": 1, "action": "Description of step 1", "example": "Example for step 1"},
            {"step": 2, "action": "Description of step 2", "example": "Example for step 2"}
          ],
          "encouragement": "A confidence-boosting message"
        }
        """
        
        let payload: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": systemPrompt],
                // Include recent messages for context (last 10)
                ] + messages.suffix(10).map { ["role": $0.isFromUser ? "user" : "assistant", "content": $0.text] } + [
                ["role": "user", "content": input]
            ],
            "temperature": 0.7,
            "max_tokens": 500,
            "response_format": ["type": "json_object"]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("Error encoding request body: \(error)")
            await MainActor.run {
                let errorMessage = ChatMessage(text: "Oops, something went wrong. Try again?", isFromUser: false)
                self.messages.append(errorMessage)
                self.saveMessageToFirestore(errorMessage)
                self.isLoading = false
            }
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String,
               let contentData = content.data(using: .utf8),
               let jsonResponse = try? JSONDecoder().decode(DatingAdvice.self, from: contentData) {
                await MainActor.run {
                    let formattedResponse = jsonResponse.steps.map { "Step \($0.step): \($0.action)\nExample: \($0.example)" }.joined(separator: "\n\n") + "\n\n\(jsonResponse.encouragement)"
                    let aiMessage = ChatMessage(text: formattedResponse, isFromUser: false)
                    self.messages.append(aiMessage)
                    self.saveMessageToFirestore(aiMessage)
                }
            } else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
            }
        } catch {
            print("OpenAI API Error: \(error)")
            await MainActor.run {
                let errorMessage = ChatMessage(text: "Oops, something went wrong. Try again?", isFromUser: false)
                self.messages.append(errorMessage)
                self.saveMessageToFirestore(errorMessage)
            }
        }
    }
    
    private func saveMessageToFirestore(_ message: ChatMessage) {
        do {
            let ref = db.collection("users").document(userID).collection("chatMessages").document()
            try ref.setData(from: message)
        } catch {
            print("Error saving message to Firestore: \(error)")
        }
    }
    
    private func loadMessagesFromFirestore() {
        db.collection("users").document(userID).collection("chatMessages")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let messages = documents.compactMap { try? $0.data(as: ChatMessage.self) }
                DispatchQueue.main.async {
                    self?.messages = messages
                }
            }
    }
}

struct DatingAdvice: Codable {
    struct Step: Codable {
        let step: Int
        let action: String
        let example: String
    }
    let steps: [Step]
    let encouragement: String
}
