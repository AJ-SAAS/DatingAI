import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account").foregroundColor(.black)) {
                    NavigationLink("Update Email") {
                        UpdateAccountView(viewModel: viewModel, mode: .email)
                    }
                    .foregroundColor(.black) // Black text on white row

                    NavigationLink("Update Password") {
                        UpdateAccountView(viewModel: viewModel, mode: .password)
                    }
                    .foregroundColor(.black) // Black text on white row

                    Button("Sign Out") {
                        viewModel.signOut()
                    }
                    .foregroundColor(.red) // Red and bold text for Sign Out
                    .bold()
                }
                .listRowBackground(Color.white) // White background for rows

                Section(header: Text("App").foregroundColor(.black)) {
                    HStack {
                        Text("Version")
                            .foregroundColor(.black) // Black text
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundColor(.gray) // Gray for version number
                    }

                    Link("Privacy Policy", destination: URL(string: "https://www.getoliviaai.app/r/privacy")!)
                        .foregroundColor(.black) // Black text
                    Link("Terms of Use", destination: URL(string: "https://www.getoliviaai.app/r/terms")!)
                        .foregroundColor(.black) // Black text
                    Link("Contact Support", destination: URL(string: "mailto:oliviaaiappsupport@gmail.com")!)
                        .foregroundColor(.black) // Black text
                }
                .listRowBackground(Color.white) // White background for rows

                Section {
                    Button("Delete Account") {
                        showDeleteConfirmation = true // Show confirmation alert
                    }
                    .foregroundColor(.red) // Red and bold text
                    .bold()
                    .alert("Delete Account", isPresented: $showDeleteConfirmation) {
                        Button("Cancel", role: .cancel) {}
                        Button("Delete", role: .destructive) {
                            // Navigation is handled by NavigationLink
                        }
                    } message: {
                        Text("Are you sure you want to delete your account? This action cannot be undone.")
                    }
                    NavigationLink(
                        destination: UpdateAccountView(viewModel: viewModel, mode: .deleteAccount),
                        isActive: Binding(
                            get: { false },
                            set: { if $0 { showDeleteConfirmation = false } }
                        )
                    ) {
                        EmptyView()
                    }
                }
                .listRowBackground(Color.white) // White background for Delete Account row
            }
            .navigationTitle("Settings")
            .foregroundColor(.black) // Default text in Form is black
            .background(Color.gray.opacity(0.9).ignoresSafeArea()) // Dark gray screen background
        }
    }
}

#Preview("iPhone 14") {
    SettingsView(viewModel: AuthViewModel())
}

#Preview("iPad Pro") {
    SettingsView(viewModel: AuthViewModel())
}
