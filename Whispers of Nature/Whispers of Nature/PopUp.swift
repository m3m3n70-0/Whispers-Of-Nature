import SwiftUI

struct PopUp: View {
    @State private var showingAlert = false
    @State private var tempName = "" // Temporary variable to hold the TextField input
    @State private var name = "" // This will hold the final submitted name
    @State private var showGreeting = false

    var body: some View {
        ZStack {
            Button("Enter name") {
                showingAlert = true
                tempName = name // Pre-fill with the current 'name' when opening the alert
            }
        }
        
        ZStack{
            if showGreeting {
                Text("Hello, \(name)!")
                    .font(.title)
                    .padding()
            }
        }
        .alert("Enter your name", isPresented: $showingAlert) {
            TextField("Enter your name", text: $tempName)
            HStack {
                Button("Cancel", role: .cancel) {
                    // Just close the alert, don't change anything
                }
                Button("OK", action: submit)
            }
        } message: {
            Text("Your name will be shown after submitting")
        }
    }

    func submit() {
        name = tempName // Only update 'name' when 'Submit' is pressed
        showGreeting = true // Display the greeting
        showingAlert = false // Dismiss the alert
    }
}

struct PopUp_Previews: PreviewProvider {
    static var previews: some View {
        PopUp()
    }
}
