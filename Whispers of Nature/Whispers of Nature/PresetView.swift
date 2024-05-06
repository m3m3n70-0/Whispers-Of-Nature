import SwiftUI

// AudioPreset model to define the structure of a preset.
struct AudioPreset: Identifiable, Codable {
    var id: UUID = UUID() // Default to a new UUID
    var name: String
    var waveVolume: Float
    var treeVolume: Float
    var fireVolume: Float
}

// PresetManager handles saving and loading presets to/from UserDefaults.
class PresetManager {
    static let shared = PresetManager()
    private let key = "presets"

    func savePresets(_ presets: [AudioPreset]) {
        if let encoded = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func loadPresets() -> [AudioPreset] {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([AudioPreset].self, from: data) {
            return decoded
        }
        return []
    }
}

struct PresetsView: View {
    @EnvironmentObject var audioVM: AudioViewModel
    @State private var presets: [AudioPreset] = []
    @State private var editingPresetId: UUID? // Keep track of which preset is being edited

    init() {
        _presets = State(initialValue: PresetManager.shared.loadPresets())
    }

    var body: some View {
        List {
            ForEach($presets, id: \.id) { $preset in
                HStack {
                    if editingPresetId == preset.id {
                        // Directly use the binding to edit the name
                        TextField("Enter Preset Name", text: $preset.name, onCommit: {
                            // Commit changes and remove editing state
                            editingPresetId = nil
                            PresetManager.shared.savePresets(presets)
                        })
                    } else {
                        // Directly access preset properties without 'wrappedValue'
                        Text(preset.name)
                    }
                    Spacer()
                    if editingPresetId != preset.id {
                        Button("Edit") {
                            editingPresetId = preset.id
                        }
                    }
                    Button("Apply") {
                        applyPreset(preset)
                    }
                    Button("Delete") {
                        withAnimation {
                            presets.removeAll { $0.id == preset.id }
                            PresetManager.shared.savePresets(presets)
                        }
                    }
                }
            }
            Button("Add New Preset") {
                addNewPreset()
            }
        }
        .navigationBarTitle("Presets", displayMode: .inline)
        .onAppear {
            presets = PresetManager.shared.loadPresets()
        }
    }

    private func applyPreset(_ preset: AudioPreset) {
        audioVM.waveVolume = preset.waveVolume
        audioVM.treeVolume = preset.treeVolume
        audioVM.fireVolume = preset.fireVolume
    }

    private func addNewPreset() {
        let newPreset = AudioPreset(name: "New Preset", waveVolume: audioVM.waveVolume, treeVolume: audioVM.treeVolume, fireVolume: audioVM.fireVolume)
        presets.append(newPreset)
        PresetManager.shared.savePresets(presets)
    }
}

// Ensure to add AudioViewModel and any other necessary parts of your app setup as needed.
