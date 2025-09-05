import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.red
                .ignoresSafeArea()
            Text("Olivia AI")
                .font(.system(size: 45, weight: .bold, design: .rounded)) // Increased from 40 to 45
                .foregroundColor(.white)
        }
    }
}

#Preview("iPhone 14") {
    SplashView()
}

#Preview("iPad Pro") {
    SplashView()
}
