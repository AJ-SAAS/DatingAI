import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text(viewModel.isSignUp ? "Create Account" : "Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)

                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)

                if viewModel.isSignUp {
                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                Button(action: {
                    viewModel.isSignUp ? viewModel.signUp() : viewModel.signIn()
                }) {
                    Text(viewModel.isSignUp ? "Sign Up" : "Sign In")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                Button(action: {
                    viewModel.isSignUp.toggle()
                }) {
                    HStack(spacing: 0) {
                        Text(viewModel.isSignUp ? "Already have an account? " : "Don't have an account? ")
                            .foregroundColor(.black)
                        Text(viewModel.isSignUp ? "Sign In" : "Sign Up")
                            .foregroundColor(.blue)
                    }
                    .font(.body)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview("iPhone 14") {
    AuthView(viewModel: AuthViewModel())
}

#Preview("iPad Pro") {
    AuthView(viewModel: AuthViewModel())
}
