import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.red
                .ignoresSafeArea()
            VStack(spacing: 20) { // Added VStack to stack image and text vertically
                Image("heartimage") // Added heartimage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100) // Adjust size as needed
                Text("Olivia AI")
                    .font(.system(size: 45, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview("iPhone 14") {
    SplashView()
}

#Preview("iPad Pro") {
    SplashView()
}
