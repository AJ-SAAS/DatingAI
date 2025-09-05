import SwiftUI

struct TabBarView: View {
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
        .accentColor(.white) // Selected tab color
        .onAppear {
            // Change unselected tab icon/text color
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.black
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.lightGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview("iPhone 14") {
    TabBarView(viewModel: AuthViewModel())
}

#Preview("iPad Pro") {
    TabBarView(viewModel: AuthViewModel())
}

