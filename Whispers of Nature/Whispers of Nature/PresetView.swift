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
    @State private var showAlertType: AlertType?
    @State private var appliedPresetName = ""
    @State private var presetToDelete: AudioPreset?

    init() {
        _presets = State(initialValue: PresetManager.shared.loadPresets())
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(presets.indices, id: \.self) { index in
                    HStack {
                        if editingPresetId == presets[index].id {
                            TextField("Enter Preset Name", text: $presets[index].name, onCommit: {
                                // Save when commit editing
                                editingPresetId = nil
                                PresetManager.shared.savePresets(presets)
                            })
                        } else {
                            Text(presets[index].name)
                                .onTapGesture {
                                    applyPreset(presets[index])
                                }
                        }
                        Spacer()
                        if editingPresetId != presets[index].id {
                            Button("Edit") {
                                editingPresetId = presets[index].id
                            }
                            .buttonStyle(BorderlessButtonStyle()) // Ensures the button doesn't capture unwanted touches
                        }
                        Spacer().frame(width: 10) // Add some space between buttons
                        Button("Delete") {
                            presetToDelete = presets[index]
                            showAlertType = .delete
                        }
                        .buttonStyle(BorderlessButtonStyle()) // Ensures the button doesn't capture unwanted touches
                    }
                }
                Button("Add New Preset") {
                    showingNewPresetSheet = true
                    newPresetName = "" // Reset the name field for new entry
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
            .alert(item: $showAlertType) { alertType in
                switch alertType {
                case .apply:
                    return Alert(title: Text("Preset Applied"), message: Text("Applied \(appliedPresetName)"), dismissButton: .default(Text("OK")))
                case .delete:
                    return Alert(
                        title: Text("Delete Preset"),
                        message: Text("Are you sure you want to delete this preset?"),
                        primaryButton: .destructive(Text("Delete")) {
                            if let preset = presetToDelete, let index = presets.firstIndex(where: { $0.id == preset.id }) {
                                deletePreset(at: index)
                            }
                            presetToDelete = nil
                        },
                        secondaryButton: .cancel {
                            presetToDelete = nil
                        }
                    )
                }
            }
        }
    }

    private func applyPreset(_ preset: AudioPreset) {
        audioVM.waveVolume = preset.waveVolume
        audioVM.treeVolume = preset.treeVolume
        audioVM.fireVolume = preset.fireVolume
        appliedPresetName = preset.name
        showAlertType = .apply
    }

    private func addNewPreset(named name: String) {
        let newPreset = AudioPreset(name: name, waveVolume: audioVM.waveVolume, treeVolume: audioVM.treeVolume, fireVolume: audioVM.fireVolume)
        presets.append(newPreset)
        PresetManager.shared.savePresets(presets)
    }

    private func deletePreset(at index: Int) {
        guard presets.indices.contains(index) else { return }
        presets.remove(at: index)
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

enum AlertType: Identifiable {
    case apply
    case delete

    var id: Int {
        hashValue
    }
}
