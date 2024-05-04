import SwiftUI
import AVKit

struct ContentView: View {
    @EnvironmentObject var audioVM: AudioViewModel

    @State private var waveVolume: Double = 0.0
    @State private var treeVolume: Double = 0.0
    @State private var fireVolume: Double = 0.0

    var body: some View {
        NavigationView {
            VStack {
                Button("Play") {
                    audioVM.playAllAudios()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 3)

                volumeControl(sound: "Waves", volume: $waveVolume, color: .blue)
                volumeControl(sound: "Trees", volume: $treeVolume, color: .green)
                volumeControl(sound: "Fire", volume: $fireVolume, color: .orange)

                Button("Stop All Audio") {
                    audioVM.stopAllAudio()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 3)

                // Navigation links to other views
                navigationLinks()

                Spacer()
            }
            .padding()
        }
    }

    func volumeControl(sound: String, volume: Binding<Double>, color: Color) -> some View {
        VStack {
            Text(sound)
                .font(.headline)
                .foregroundColor(color)
                .padding(.bottom, 2)

            Slider(value: volume, in: 0...1) {
                Text("\(sound) Volume")
            }
            .onChange(of: volume.wrappedValue) { newValue in
                audioVM.setVolume(for: sound.lowercased(), volume: Float(newValue))
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AudioViewModel())
    }
}
