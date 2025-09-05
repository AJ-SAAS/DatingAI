import SwiftUI

enum UpdateAccountMode {
    case email
    case password
    case deleteAccount
}

struct UpdateAccountView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var newValue: String = "" // New email or password
    @State private var currentPassword: String = ""
    @State private var errorMessage: String?
    @Environment(\.dismiss) var dismiss
    let mode: UpdateAccountMode

    var body: some View {
        Form {
            Section(header: Text(headerText)) {
                if mode != .deleteAccount {
                    TextField(mode == .email ? "New Email" : "New Password", text: $newValue)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                }
                SecureField("Current Password", text: $currentPassword)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                Button(actionText) {
                    errorMessage = nil
                    switch mode {
                    case .email:
                        viewModel.updateEmail(newEmail: newValue, currentPassword: currentPassword) { error in
                            if let error = error {
                                errorMessage = error.localizedDescription
                            } else {
                                dismiss()
                            }
                        }
                    case .password:
                        viewModel.updatePassword(newPassword: newValue, currentPassword: currentPassword) { error in
                            if let error = error {
                                errorMessage = error.localizedDescription
                            } else {
                                dismiss()
                            }
                        }
                    case .deleteAccount:
                        viewModel.deleteAccount(currentPassword: currentPassword) { error in
                            if let error = error {
                                errorMessage = error.localizedDescription
                            } else {
                                dismiss()
                            }
                        }
                    }
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(mode == .deleteAccount ? Color.red : Color.red) // Red button for all actions to match theme
                .cornerRadius(8)
            }
            .listRowBackground(Color.gray.opacity(0.8))
        }
        .navigationTitle(headerText)
        .background(Color.gray.opacity(0.9).ignoresSafeArea())
    }

    private var headerText: String {
        switch mode {
        case .email:
            return "Update Email"
        case .password:
            return "Update Password"
        case .deleteAccount:
            return "Delete Account"
        }
    }

    private var actionText: String {
        mode == .deleteAccount ? "Delete Account" : "Save Changes"
    }
}

#Preview("iPhone 14") {
    UpdateAccountView(viewModel: AuthViewModel(), mode: .email)
}

#Preview("iPad Pro") {
    UpdateAccountView(viewModel: AuthViewModel(), mode: .deleteAccount)
}
