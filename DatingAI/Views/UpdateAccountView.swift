import SwiftUI

enum UpdateAccountMode {
    case email
    case password
    case deleteAccount
}

struct UpdateAccountView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var newValue: String = ""
    @State private var currentPassword: String = ""
    @State private var errorMessage: String?
    @Environment(\.dismiss) var dismiss
    let mode: UpdateAccountMode

    var body: some View {
        Form {
            Section(header: Text(headerText)) {
                if mode != .deleteAccount {
                    TextField(placeholderText, text: $newValue)
                        .textFieldStyle(.plain)
                        .padding()
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                SecureField("Current Password", text: $currentPassword)
                    .textFieldStyle(.plain)
                    .padding()
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
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
                .background(Color.red)
                .cornerRadius(8)
            }
            .listRowBackground(Color.white)
        }
        .navigationTitle(headerText)
        .background(Color.gray.opacity(0.9).ignoresSafeArea())
        .navigationBarBackButtonHidden(true) // Hide default back button
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Settings")
                    }
                    .foregroundColor(.gray) // Dark gray back button
                }
            }
        }
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

    private var placeholderText: String {
        switch mode {
        case .email:
            return "Enter new email here"
        case .password:
            return "Enter new password here"
        case .deleteAccount:
            return ""
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
