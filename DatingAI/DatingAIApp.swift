import SwiftUI
import Firebase

@main
struct DatingAIApp: App {
    
    init() {
        FirebaseApp.configure()
        
        // ❗️DEV ONLY: force sign-out for testing Auth flow
        // Comment this out or remove it before release
        // try? Auth.auth().signOut()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
