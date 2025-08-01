import SwiftUI

struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()

    var body: some View {
        Form {
            Section(header: Text("Profile Photo")) {
                HStack {
                    Spacer()
                    if let image = viewModel.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }

                Button("Change Photo") {
                    // We'll handle this in a future step
                }
            }

            Section(header: Text("Name")) {
                TextField("Enter your name", text: $viewModel.name)
            }

            Section {
                Button("Save Changes") {
                    viewModel.saveUserProfile()
                }
            }
        }
        .navigationTitle("Edit Profile")
        .onAppear {
            viewModel.loadUserProfile()
        }
    }
}
