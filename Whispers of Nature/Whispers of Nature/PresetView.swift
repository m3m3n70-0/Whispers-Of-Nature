import SwiftUI
import Foundation

// Define the Audio Preset Model
struct AudioPreset: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var waveVolume: Float
    var treeVolume: Float
    var fireVolume: Float
}

// Preset Manager for saving and loading presets
class PresetManager {
    static let shared = PresetManager()
    private let presetsKey = "audioPresets"
    
    func savePresets(_ presets: [AudioPreset]) {
        if let data = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(data, forKey: presetsKey)
        }
    }

    func loadPresets() -> [AudioPreset] {
        if let data = UserDefaults.standard.data(forKey: presetsKey),
           let presets = try? JSONDecoder().decode([AudioPreset].self, from: data) {
            return presets
        }
        return []
    }

    func deletePreset(_ preset: AudioPreset) {
        var presets = loadPresets()
        presets.removeAll { $0.id == preset.id }
        savePresets(presets)
    }
}

// SwiftUI View for Managing Presets
struct PresetsView: View {
    @State private var presets: [AudioPreset] = PresetManager.shared.loadPresets()
    @State private var newPresetName = ""
    @State private var waveVolume: Float = 0.5
    @State private var treeVolume: Float = 0.5
    @State private var fireVolume: Float = 0.5

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(presets) { preset in
                        HStack {
                            Text(preset.name)
                            Spacer()
                            Button(action: {
                                PresetManager.shared.deletePreset(preset)
                                presets = PresetManager.shared.loadPresets()
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                TextField("Preset Name", text: $newPresetName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Slider(value: $waveVolume, in: 0...1, step: 0.1) {
                    Text("Wave Volume")
                }
                .padding()

                Slider(value: $treeVolume, in: 0...1, step: 0.1) {
                    Text("Tree Volume")
                }
                .padding()

                Slider(value: $fireVolume, in: 0...1, step: 0.1) {
                    Text("Fire Volume")
                }
                .padding()

                Button("Save Preset") {
                    let newPreset = AudioPreset(name: newPresetName, waveVolume: waveVolume, treeVolume: treeVolume, fireVolume: fireVolume)
                    presets.append(newPreset)
                    PresetManager.shared.savePresets(presets)
                    newPresetName = "" // Clear the text field after saving
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Audio Presets")
        }
    }
}


