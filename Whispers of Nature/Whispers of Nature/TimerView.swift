import SwiftUI

struct TimerView: View {
    @EnvironmentObject var audioVM: AudioViewModel
    @State private var remainingTime = 60
    @State private var enteredTime = ""

    var body: some View {
        VStack {
            TextField("Enter time in seconds", text: $enteredTime)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Start Timer") {
                startTimer()
            }
            
            Text("Time Remaining: \(remainingTime)")
        }
        .padding()
    }

    func startTimer() {
        guard let duration = Int(enteredTime) else { return }
        remainingTime = duration
       
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                DispatchQueue.main.async {
                    if self.remainingTime > 0 {
                        self.remainingTime -= 1
                    } else {
                        timer.invalidate()
                        audioVM.stopAllAudio()
                    }
                }
            }
    
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView().environmentObject(AudioViewModel())
    }
}
