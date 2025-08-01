import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isSignedIn = false
    @Published var isSignUp = false // toggle between login/signup

    private var cancellables = Set<AnyCancellable>()

    init() {
        self.isSignedIn = Auth.auth().currentUser != nil
    }

    func signUp() {
        guard password == confirmPassword else {
            print("Passwords do not match")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Sign Up Error: \(error.localizedDescription)")
            } else if let user = result?.user {
                self?.createUserProfile(uid: user.uid, email: user.email ?? "")
                self?.isSignedIn = true
            }
        }
    }

    private func createUserProfile(uid: String, email: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "email": email,
            "name": "",
            "profileImageURL": ""
        ]) { error in
            if let error = error {
                print("Error creating user profile: \(error.localizedDescription)")
            }
        }
    }

    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Sign In Error: \(error.localizedDescription)")
            } else {
                self?.isSignedIn = true
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isSignedIn = false
        } catch {
            print("Sign Out Error: \(error.localizedDescription)")
        }
    }
}
