import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showSplash = true
    @State private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                                if viewModel.isSignedIn {
                                    viewModel.checkOnboardingStatus { completed in
                                        hasCompletedOnboarding = completed
                                    }
                                }
                            }
                        }
                    }
            } else if !hasCompletedOnboarding && !viewModel.isSignedIn {
                OnboardingView(viewModel: viewModel, hasCompletedOnboarding: $hasCompletedOnboarding)
            } else {
                if viewModel.isSignedIn {
                    TabBarView(viewModel: viewModel)
                } else {
                    AuthView(viewModel: viewModel)
                }
            }
        }
        .animation(.easeInOut, value: showSplash)
        .animation(.easeInOut, value: hasCompletedOnboarding)
        .animation(.easeInOut, value: viewModel.isSignedIn)
    }
}

#Preview("iPhone 14") {
    ContentView()
        .environmentObject(AuthViewModel())
}

#Preview("iPad Pro") {
    ContentView()
        .environmentObject(AuthViewModel())
}
