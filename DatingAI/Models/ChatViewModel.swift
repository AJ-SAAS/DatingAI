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
        
        // Initial welcome message
        let welcomeMessage = ChatMessage(
            text: "Hey! I'm Olivia, your dating coach winggirl. 😏 Whether you need a quick one-liner or playful advice, I’ve got your back.",
            isFromUser: false,
            timestamp: Date()
        )
        messages.append(welcomeMessage)
        saveMessageToFirestore(welcomeMessage)
        
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
        You are Olivia Alexa, a witty and supportive dating coach AI. 
        Respond in **short, punchy, playful one-liners or questions**, maximum 1–3 sentences. 
        Avoid writing paragraphs or long lists. Be confident, flirty, and encouraging. Always avoid toxic, rude or degrading language. Keep it confident and high-value.
        Keep it high-value and respectful. End with a quick confidence boost like “You got this.”
        """
        
        let payload: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt]
            ] + messages.suffix(10).map { ["role": $0.isFromUser ? "user" : "assistant", "content": $0.text] } + [
                ["role": "user", "content": input]
            ],
            "temperature": 0.85,
            "max_tokens": 150
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("Error encoding request body: \(error)")
            await handleError()
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                
                await MainActor.run {
                    let aiMessage = ChatMessage(text: content.trimmingCharacters(in: .whitespacesAndNewlines), isFromUser: false)
                    self.messages.append(aiMessage)
                    self.saveMessageToFirestore(aiMessage)
                }
            } else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
            }
        } catch {
            print("OpenAI API Error: \(error)")
            await handleError()
        }
    }
    
    private func handleError() async {
        await MainActor.run {
            let errorMessage = ChatMessage(text: "Oops, something went wrong. Try again?", isFromUser: false)
            self.messages.append(errorMessage)
            self.saveMessageToFirestore(errorMessage)
            self.isLoading = false
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
