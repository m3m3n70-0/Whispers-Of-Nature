import SwiftUI

struct TimerView: View {
    @EnvironmentObject var audioVM: AudioViewModel
    @State private var hours = 0
    @State private var minutes = 0
    @State private var seconds = 0
    @State private var remainingTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var isTimerRunning = false
    @State private var startTime: Date?
    @State private var totalDuration: TimeInterval = 0

    var body: some View {
        ZStack {
            BackgroundView()
            VStack(spacing: 20) {
                Spacer().frame(height: 20)
                
                HStack {
                    Picker("Hours", selection: $hours) {
                        ForEach(0..<24) { Text("\($0) h").tag($0) }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)

                    Picker("Minutes", selection: $minutes) {
                        ForEach(0..<60) { Text("\($0) m").tag($0) }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)
                    
                    Picker("Seconds", selection: $seconds) {
                        ForEach(0..<60) { Text("\($0) s").tag($0) }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
                .padding(.horizontal)
                
                HStack(spacing: 20) {
                    Button(action: {
                        if self.isTimerRunning {
                            self.pauseTimer()
                        } else {
                            self.startTimer()
                        }
                    }) {
                        Image(systemName: isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(isTimerRunning ? .yellow : .green)
                    }

                    Button(action: resetTimer) {
                        Image(systemName: "stop.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                
                Text("Time Remaining: \(formatTime(remainingTime))")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Timer", displayMode: .large)
            .navigationBarItems(trailing: profileButton)
            .onAppear {
                self.loadTimerState()
                self.updateRemainingTime()
                if self.isTimerRunning {
                    self.startTimer()
                }
            }
            .onDisappear {
                self.saveTimerState()
            }
        }
    }

    private var profileButton: some View {
        Button(action: {
            // Action for profile button
        }) {
            Image(systemName: "person.crop.circle")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.white)
        }
    }

    func startTimer() {
        if !isTimerRunning {
            startTime = Date()
            totalDuration = TimeInterval(hours * 3600 + minutes * 60 + seconds)
            isTimerRunning = true
            saveTimerState()
        }

        if remainingTime == 0 {
            remainingTime = totalDuration
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            DispatchQueue.main.async {
                self.updateRemainingTime()
                if self.remainingTime <= 0 {
                    timer.invalidate()
                    self.isTimerRunning = false
                    self.remainingTime = 0
                    audioVM.stopAllAudio()
                }
            }
        }
    }

    func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
        updateRemainingTime()
        saveTimerState()
    }

    func resetTimer() {
        pauseTimer()
        remainingTime = 1 // Set remainingTime to 1 to avoid stopping the music
        hours = 0
        minutes = 0
        seconds = 0
        startTime = nil
        totalDuration = 0
        saveTimerState()
    }

    func updateRemainingTime() {
        if let start = startTime {
            let elapsedTime = Date().timeIntervalSince(start)
            remainingTime = max(1, totalDuration - elapsedTime) // Ensure remainingTime doesn't go to 0
        }
    }

    func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func saveTimerState() {
        UserDefaults.standard.set(remainingTime, forKey: "remainingTime")
        UserDefaults.standard.set(isTimerRunning, forKey: "isTimerRunning")
        if let startTime = startTime {
            UserDefaults.standard.set(startTime, forKey: "startTime")
        }
        UserDefaults.standard.set(totalDuration, forKey: "totalDuration")
    }

    func loadTimerState() {
        remainingTime = UserDefaults.standard.double(forKey: "remainingTime")
        isTimerRunning = UserDefaults.standard.bool(forKey: "isTimerRunning")
        startTime = UserDefaults.standard.object(forKey: "startTime") as? Date
        totalDuration = UserDefaults.standard.double(forKey: "totalDuration")

        if isTimerRunning {
            updateRemainingTime()
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView().environmentObject(AudioViewModel())
    }
}
