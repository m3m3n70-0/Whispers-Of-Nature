//import SwiftUI
//import LocalAuthentication
//
//struct PasswordView: View {
//    @State private var isAuthenticated = false
//    @State private var authenticationError: Error?
//
//    var body: some View {
//        if isAuthenticated {
//            Text("Protected Content") // Replace with your protected content
//        } else {
//            VStack {
//                Button(action: {
//                    authenticateUser()
//                }) {
//                    Text("Authenticate")
//                }
//                .padding()
//
//                if let error = authenticationError {
//                    Text("Authentication failed: \(error.localizedDescription)")
//                        .foregroundColor(.red)
//                        .padding()
//                }
//            }
//            .padding()
//        }
//    }
//
//    private func authenticateUser() {
//        let context = LAContext()
//        var error: NSError?
//
//        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access your secure data") { success, error in
//                DispatchQueue.main.async {
//                    if success {
//                        isAuthenticated = true
//                        authenticationError = nil
//                    } else {
//                        authenticationError = error
//                    }
//                }
//            }
//        } else {
//            authenticationError = error
//        }
//    }
//}
//
