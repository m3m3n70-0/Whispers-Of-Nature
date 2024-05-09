import SwiftUI

struct ContentView: View {
    @EnvironmentObject var audioVM: AudioViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer().frame(height: 20)
                        
                        playButton
                        
                        volumeControls
                        
                        navigationGrid
                        
                        Spacer()
                    }
                    .padding()
                    .navigationBarTitle("Whispers of Nature", displayMode: .large)
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
            .padding()
            .frame(maxWidth: .infinity)
            .background(audioVM.isAudioPlaying ? Color.red : Color.green)
            .foregroundColor(.white)
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 5)
            .scaleEffect(audioVM.isAudioPlaying ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: audioVM.isAudioPlaying)
        }
        .padding(.horizontal)
    }
    
    private var volumeControls: some View {
        VStack(spacing: 20) {
            volumeControl(sound: "Waves", volume: $audioVM.waveVolume, color: .blue)
            volumeControl(sound: "Trees", volume: $audioVM.treeVolume, color: .green)
            volumeControl(sound: "Fire", volume: $audioVM.fireVolume, color: .orange)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.8))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
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
        .background(Color(.systemGray6).opacity(0.7))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 3)
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
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
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
