import Foundation
import FirebaseFirestore

struct ChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    let text: String
    let isFromUser: Bool
    let timestamp: Date
    
    init(id: String? = nil, text: String, isFromUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }
}
