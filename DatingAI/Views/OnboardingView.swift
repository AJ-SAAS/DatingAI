import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    let onboardingScreens: [(title: String, description: String, image: String?)] = [
        (
            "Welcome to Olivia AI",
            "Your personal AI winggirl to guide you through dating with confidence.",
            "bubble.left.and.exclamationmark.fill"
        ),
        (
            "Confidence & Control",
            "Olivia helps you make the right moves with personalized advice.",
            "manimage"
        ),
        (
            "Spot Red Flags",
            "Stay ahead by identifying potential issues before they arise.",
            "flagimage"
        ),
        (
            "Status & Success",
            "Level up your dating game and achieve your goals with Olivia.",
            "crownimage"
        ),
        (
            "Trusted by Many",
            "Hear from users who’ve transformed their dating lives with Olivia.",
            "reviewimage"
        ),
        (
            "Create Your Account to Get Started",
            "Ready to take control of your dating journey? Let’s go!",
            nil
        )
    ]
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // Top progress bar
                ProgressBar(numberOfPages: onboardingScreens.count, currentPage: $currentPage)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingScreens.count, id: \.self) { index in
                        OnboardingPageView(
                            title: onboardingScreens[index].title,
                            description: onboardingScreens[index].description,
                            image: onboardingScreens[index].image,
                            isFirstPage: index == 0,
                            isLastPage: index == onboardingScreens.count - 1
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                
                // Continue Button
                Button(action: {
                    if currentPage < onboardingScreens.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage += 1
                        }
                    } else {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            hasCompletedOnboarding = true
                            if viewModel.isSignedIn {
                                viewModel.markOnboardingComplete()
                            }
                        }
                    }
                }) {
                    Text(currentPage == onboardingScreens.count - 1 ? "Get Started" : "Continue")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPageView: View {
    let title: String
    let description: String
    let image: String?
    let isFirstPage: Bool
    let isLastPage: Bool
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showTagline = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text(title)
                .font(.system(size: 29, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 40)
            
            // Non-first page description
            if !isFirstPage {
                Text(description)
                    .font(.system(size: 22, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            if isFirstPage {
                VStack(spacing: 12) { // reduced spacing
                    Spacer()
                    Text(description)
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                        .italic()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .opacity(showTagline ? 1 : 0)
                        .offset(y: showTagline ? 0 : 20)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                                showTagline = true
                            }
                        }
                    
                    if let img = image {
                        imageView(img)
                    }
                    Spacer()
                }
            } else {
                if let img = image {
                    imageView(img)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private func imageView(_ imageName: String) -> some View {
        if imageName.contains(".fill") {
            let size: CGFloat = (horizontalSizeClass == .regular) ? 400 : 260
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: size, maxHeight: size)
                .foregroundColor(.white)
                .padding(.vertical, 12) // moved up by reducing padding
        } else {
            let height: CGFloat = (horizontalSizeClass == .regular) ? 450 : 300
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .padding(.vertical, 12) // moved up slightly
        }
    }
}

struct ProgressBar: View {
    let numberOfPages: Int
    @Binding var currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Capsule()
                    .frame(width: 30, height: 4)
                    .foregroundColor(index <= currentPage ? .white : .white.opacity(0.3))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview("iPhone 14") {
    OnboardingView(viewModel: AuthViewModel(), hasCompletedOnboarding: .constant(false))
}

#Preview("iPad Pro") {
    OnboardingView(viewModel: AuthViewModel(), hasCompletedOnboarding: .constant(false))
}

