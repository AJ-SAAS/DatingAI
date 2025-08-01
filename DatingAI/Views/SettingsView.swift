import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    Button("Sign Out", role: .destructive) {
                        viewModel.signOut()
                    }
                }

                Section(header: Text("App")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundColor(.gray)
                    }

                    Link("Privacy Policy", destination: URL(string: "https://yourdomain.com/privacy")!)
                    Link("Terms of Use", destination: URL(string: "https://yourdomain.com/terms")!)
                    Link("Contact Support", destination: URL(string: "mailto:support@yourdomain.com")!)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
