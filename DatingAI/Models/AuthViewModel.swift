import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isSignedIn = false
    @Published var isSignUp = true // Changed to true for default sign-up mode

    private var cancellables = Set<AnyCancellable>()
    private let db = Firestore.firestore()

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
        db.collection("users").document(uid).setData([
            "email": email,
            "name": "",
            "profileImageURL": "",
            "hasCompletedOnboarding": false
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

    func checkOnboardingStatus(completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Error checking onboarding status: \(error.localizedDescription)")
                completion(false)
            } else if let data = snapshot?.data(), let hasCompleted = data["hasCompletedOnboarding"] as? Bool {
                completion(hasCompleted)
            } else {
                completion(false)
            }
        }
    }

    func markOnboardingComplete() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user signed in to mark onboarding complete")
            return
        }
        db.collection("users").document(uid).updateData([
            "hasCompletedOnboarding": true
        ]) { error in
            if let error = error {
                print("Error updating onboarding status: \(error.localizedDescription)")
            }
        }
    }
}
