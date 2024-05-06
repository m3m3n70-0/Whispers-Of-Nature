import SwiftUI

struct ContentView: View {
    @EnvironmentObject var audioVM: AudioViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                playButton
                
                volumeControl(sound: "Waves", volume: $audioVM.waveVolume, color: .blue)
                volumeControl(sound: "Trees", volume: $audioVM.treeVolume, color: .green)
                volumeControl(sound: "Fire", volume: $audioVM.fireVolume, color: .orange)
                
                navigationLinks()
                
                Spacer()
            }
            .padding()
        }
    }
    
    private var playButton: some View {
        Button(action: toggleAudio) {
            Text(audioVM.isAudioPlaying ? "Stop All Audio" : "Play")
                .padding()
                .background(audioVM.isAudioPlaying ? Color.red : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 3)
        }
    }
    
    private func toggleAudio() {
        if audioVM.isAudioPlaying {
            audioVM.stopAllAudio()
        } else {
            audioVM.playAllAudios()
        }
    }
    
    @ViewBuilder
    func volumeControl(sound: String, volume: Binding<Float>, color: Color) -> some View {
        VStack {
            Text(sound)
                .font(.headline)
                .foregroundColor(color)
                .padding(.bottom, 2)
            
            Slider(value: volume, in: 0...1) {
                Text("\(sound) Volume")
            }
            .accentColor(color)
            .padding()
            
            HStack {
                Spacer()
                Text("\(Int(volume.wrappedValue * 100))% Volume")
                    .foregroundColor(color)
            }
        }
    }
    
    @ViewBuilder
    func navigationLinks() -> some View {
        NavigationLink(destination: SettingsView()) {
            Text("Settings")
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 2)
        }
        NavigationLink(destination: PopUp()) {
            Text("PopUp")
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 2)
        }
        NavigationLink(destination: PresetsView().environmentObject(audioVM)) {
            Text("Presets")
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 2)
        }
        NavigationLink(destination: TimerView()) {
            Text("Timer")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 2)
        }
    }
}
