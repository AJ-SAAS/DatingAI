import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import SwiftUI

class UserProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var profileImage: UIImage?
    @Published var isLoading = false

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let uid = Auth.auth().currentUser?.uid

    func loadUserProfile() {
        guard let uid else { return }
        isLoading = true
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            if let data = snapshot?.data() {
                DispatchQueue.main.async {
                    self?.name = data["name"] as? String ?? ""
                }
                if let urlString = data["profileImageURL"] as? String,
                   let url = URL(string: urlString) {
                    self?.loadImage(from: url)
                }
            }
        }
    }

    func saveUserProfile() {
        guard let uid else { return }
        db.collection("users").document(uid).updateData([
            "name": name
        ]) { error in
            if let error = error {
                print("Error saving name: \(error)")
            }
        }

        if let image = profileImage {
            uploadProfileImage(image)
        }
    }

    private func uploadProfileImage(_ image: UIImage) {
        guard let uid, let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let ref = storage.reference().child("profileImages/\(uid).jpg")
        ref.putData(imageData) { _, error in
            if let error = error {
                print("Upload failed: \(error)")
                return
            }

            ref.downloadURL { [weak self] url, _ in
                if let url = url {
                    self?.db.collection("users").document(uid).updateData([
                        "profileImageURL": url.absoluteString
                    ])
                }
            }
        }
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }
        }.resume()
    }
}
