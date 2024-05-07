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
    @State private var editingPresetId: UUID?
    @State private var showingNewPresetSheet = false
    @State private var newPresetName = ""

    init() {
        _presets = State(initialValue: PresetManager.shared.loadPresets())
    }

    var body: some View {
        List {
            ForEach(presets.indices, id: \.self) { index in
                HStack {
                    if editingPresetId == presets[index].id {
                        TextField("Enter Preset Name", text: $presets[index].name) {
                            presets[index].name = presets[index].name.trimmingCharacters(in: .whitespacesAndNewlines)
                            PresetManager.shared.savePresets(presets)
                            editingPresetId = nil
                        }
                    } else {
                        Text(presets[index].name)
                    }
                    Spacer()
                    Button("Edit") {
                        editingPresetId = presets[index].id
                    }
                    Button("Apply") {
                        applyPreset(presets[index])
                    }
                    Button("Delete") {
                        withAnimation {
                            presets.remove(at: index)
                            PresetManager.shared.savePresets(presets)
                        }
                    }
                }
            }
            Button("Add New Preset") {
                showingNewPresetSheet = true
            }
        }
        .navigationBarTitle("Presets", displayMode: .inline)
        .onAppear {
            presets = PresetManager.shared.loadPresets()
        }
        .sheet(isPresented: $showingNewPresetSheet) {
            NewPresetView(newPresetName: $newPresetName, onSave: {
                addNewPreset(named: newPresetName)
                showingNewPresetSheet = false
            }, onCancel: {
                showingNewPresetSheet = false
            })
        }
    }

    private func applyPreset(_ preset: AudioPreset) {
        audioVM.waveVolume = preset.waveVolume
        audioVM.treeVolume = preset.treeVolume
        audioVM.fireVolume = preset.fireVolume
    }

    private func addNewPreset(named name: String) {
        let newPreset = AudioPreset(name: name, waveVolume: audioVM.waveVolume, treeVolume: audioVM.treeVolume, fireVolume: audioVM.fireVolume)
        presets.append(newPreset)
        PresetManager.shared.savePresets(presets)
    }
}

struct NewPresetView: View {
    @Binding var newPresetName: String
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Preset Name", text: $newPresetName)
                Button("Save Preset") {
                    onSave()
                }
            }
            .navigationBarTitle("New Preset", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                onCancel()
            })
        }
    }
}





