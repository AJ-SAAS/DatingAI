import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isSignedIn = false
    @Published var isSignUp = true

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

    func updateEmail(newEmail: String, currentPassword: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"]))
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                print("Reauthentication Error: \(error.localizedDescription)")
                completion(error)
                return
            }

            user.updateEmail(to: newEmail) { error in
                if let error = error {
                    print("Update Email Error: \(error.localizedDescription)")
                    completion(error)
                    return
                }

                self.db.collection("users").document(user.uid).updateData([
                    "email": newEmail
                ]) { error in
                    if let error = error {
                        print("Error updating Firestore email: \(error.localizedDescription)")
                    }
                    completion(error)
                }
            }
        }
    }

    func updatePassword(newPassword: String, currentPassword: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"]))
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                print("Reauthentication Error: \(error.localizedDescription)")
                completion(error)
                return
            }

            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    print("Update Password Error: \(error.localizedDescription)")
                }
                completion(error)
            }
        }
    }

    func deleteAccount(currentPassword: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"]))
            return
        }

        // Reauthenticate user before deleting account
        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                print("Reauthentication Error: \(error.localizedDescription)")
                completion(error)
                return
            }

            // Delete Firestore user data
            self.db.collection("users").document(user.uid).delete { error in
                if let error = error {
                    print("Error deleting Firestore data: \(error.localizedDescription)")
                    completion(error)
                    return
                }

                // Delete Firebase Auth account
                user.delete { error in
                    if let error = error {
                        print("Delete Account Error: \(error.localizedDescription)")
                    } else {
                        self.isSignedIn = false
                    }
                    completion(error)
                }
            }
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
