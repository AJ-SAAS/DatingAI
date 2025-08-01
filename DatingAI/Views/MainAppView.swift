import SwiftUI

struct MainAppView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        TabView {
            ChatView()
                .tabItem {
                    Label("Home", systemImage: "message.fill")
                }

            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
