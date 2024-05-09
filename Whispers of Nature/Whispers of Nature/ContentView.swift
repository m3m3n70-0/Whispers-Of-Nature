import SwiftUI

struct ContentView: View {
    @EnvironmentObject var audioVM: AudioViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                ScrollView {
                    VStack(spacing: 20) {  // Adjusted spacing from 30 to 20
                        Spacer().frame(height: 10)  // Adjusted height from 20 to 10
                        
                        playButton
                        
                        volumeControls
                        
                        navigationGrid
                        
                        Spacer()
                    }
                    .padding()
                    .navigationBarItems(trailing: profileButton)
                }
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
    
    private var playButton: some View {
        Button(action: toggleAudio) {
            HStack {
                Image(systemName: audioVM.isAudioPlaying ? "stop.fill" : "play.fill")
                    .font(.title2)
                Text(audioVM.isAudioPlaying ? "Stop All Audio" : "Play All Audio")
                    .fontWeight(.semibold)
                    .font(.title2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(audioVM.isAudioPlaying ? Color.red : Color.green)
        .foregroundColor(.white)
        .cornerRadius(15)
        .padding(.horizontal)
    }
    
    private var volumeControls: some View {
        VStack(spacing: 20) {
            volumeControl(sound: "Waves", volume: $audioVM.waveVolume, color: .blue)
            volumeControl(sound: "Trees", volume: $audioVM.treeVolume, color: .green)
            volumeControl(sound: "Fire", volume: $audioVM.fireVolume, color: .orange)
        }
        .padding()
        .background(Color.white.opacity(0.1)) // Make background transparent
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.8), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func volumeControl(sound: String, volume: Binding<Float>, color: Color) -> some View {
        VStack {
            HStack {
                Text(sound)
                    .font(.headline)
                    .foregroundColor(color)
                Spacer()
                Text("\(Int(volume.wrappedValue * 100))%")
                    .font(.subheadline)
                    .foregroundColor(color)
            }
            
            Slider(value: volume, in: 0...1)
                .accentColor(color)
                .padding(.horizontal)
        }
        .padding()
    }
    
    private var navigationGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
            navigationIcon(destination: SettingsView(), icon: "gearshape.fill", color: .gray)
            navigationIcon(destination: PopUp(), icon: "message.fill", color: .gray)
            navigationIcon(destination: PresetsView().environmentObject(audioVM), icon: "list.bullet", color: .gray)
            navigationIcon(destination: TimerView(), icon: "timer", color: .blue)
        }
        .padding(.horizontal)
    }
    
    private func navigationIcon<Destination: View>(destination: Destination, icon: String, color: Color) -> some View {
        NavigationLink(destination: destination) {
            VStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(color)
                    .clipShape(Circle())
                    .shadow(color: .clear, radius: 5, x: 0, y: 5)
            }
        }
    }
    
    private func toggleAudio() {
        withAnimation {
            if audioVM.isAudioPlaying {
                audioVM.stopAllAudio()
            } else {
                audioVM.playAllAudios()
            }
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
