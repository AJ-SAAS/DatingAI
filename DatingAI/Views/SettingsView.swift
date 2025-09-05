import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var showDeleteConfirmation = false
    @State private var navigateToDeleteAccount = false // Control navigation programmatically

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account").foregroundColor(.black)) {
                    NavigationLink("Update Email") {
                        UpdateAccountView(viewModel: viewModel, mode: .email)
                    }
                    .foregroundColor(.black)

                    NavigationLink("Update Password") {
                        UpdateAccountView(viewModel: viewModel, mode: .password)
                    }
                    .foregroundColor(.black)

                    Button("Sign Out") {
                        viewModel.signOut()
                    }
                    .foregroundColor(.red)
                    .bold()
                }
                .listRowBackground(Color.white)

                Section(header: Text("App").foregroundColor(.black)) {
                    HStack {
                        Text("Version")
                            .foregroundColor(.black)
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundColor(.gray)
                    }

                    Link("Privacy Policy", destination: URL(string: "https://www.getoliviaai.app/r/privacy")!)
                        .foregroundColor(.black)
                    Link("Terms of Use", destination: URL(string: "https://www.getoliviaai.app/r/terms")!)
                        .foregroundColor(.black)
                    Link("Contact Support", destination: URL(string: "mailto:oliviaaiappsupport@gmail.com")!)
                        .foregroundColor(.black)
                }
                .listRowBackground(Color.white)

                Section {
                    Button("Delete Account") {
                        showDeleteConfirmation = true
                    }
                    .foregroundColor(.red)
                    .bold()
                    .alert("Delete Account", isPresented: $showDeleteConfirmation) {
                        Button("Cancel", role: .cancel) {}
                        Button("Delete", role: .destructive) {
                            navigateToDeleteAccount = true // Trigger navigation
                        }
                    } message: {
                        Text("Are you sure you want to delete your account? This action cannot be undone.")
                    }
                }
                .listRowBackground(Color.white)

                // Programmatic navigation for Delete Account
                NavigationLink(
                    destination: UpdateAccountView(viewModel: viewModel, mode: .deleteAccount),
                    isActive: $navigateToDeleteAccount
                ) {
                    EmptyView()
                }
                .hidden() // Ensure no visible row
            }
            .navigationTitle("Settings")
            .foregroundColor(.black)
            .background(Color.gray.opacity(0.9).ignoresSafeArea())
        }
    }
}

#Preview("iPhone 14") {
    SettingsView(viewModel: AuthViewModel())
}

#Preview("iPad Pro") {
    SettingsView(viewModel: AuthViewModel())
}
