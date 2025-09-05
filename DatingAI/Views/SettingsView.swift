import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account").foregroundColor(.black)) {
                    Button("Sign Out", role: .destructive) {
                        viewModel.signOut()
                    }
                    .foregroundColor(.black) // Black text on white cell background
                }

                Section(header: Text("App").foregroundColor(.black)) {
                    HStack {
                        Text("Version")
                            .foregroundColor(.black) // Black text
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundColor(.gray) // Keep gray for version number
                    }

                    Link("Privacy Policy", destination: URL(string: "https://www.getoliviaai.app/r/privacy")!)
                        .foregroundColor(.black) // Black text
                    Link("Terms of Use", destination: URL(string: "https://www.getoliviaai.app/r/terms")!)
                        .foregroundColor(.black) // Black text
                    Link("Contact Support", destination: URL(string: "mailto:oliviaaiappsupport@gmail.com")!)
                        .foregroundColor(.black) // Black text
                }
            }
            .navigationTitle("Settings")
            .foregroundColor(.black) // Ensure default text in Form is black
        }
        .background(Color(.systemGray6).ignoresSafeArea()) // Very dark gray background
    }
}

#Preview("iPhone 14") {
    SettingsView(viewModel: AuthViewModel())
}

#Preview("iPad Pro") {
    SettingsView(viewModel: AuthViewModel())
}
