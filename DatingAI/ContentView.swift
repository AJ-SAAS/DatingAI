import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        Group {
            if viewModel.isSignedIn {
                MainAppView(viewModel: viewModel)
            } else {
                AuthView(viewModel: viewModel)
            }
        }
        .animation(.easeInOut, value: viewModel.isSignedIn)
    }
}
