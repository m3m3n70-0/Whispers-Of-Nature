import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    @State private var isAuthenticated = false
    @State private var authenticationError: Error?

    var body: some View {
        if isAuthenticated {
            Text("Protected Content") // Replace with your protected content
        } else {
            VStack {
                Button("Authenticate") {
                    authenticateUser()
                }
                .padding()

                if let error = authenticationError {
                    Text("Authentication failed: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
        }
    }

    private func authenticateUser() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Access your secure data") { success, error in
                DispatchQueue.main.async {
                    handleAuthenticationResult(success, error: error)
                }
            }
        } else {
            authenticationError = error
        }
    }

    private func handleAuthenticationResult(_ success: Bool, error: Error?) {
        if success {
            isAuthenticated = true
            authenticationError = nil
        } else {
            authenticationError = error
        }
    }
}
