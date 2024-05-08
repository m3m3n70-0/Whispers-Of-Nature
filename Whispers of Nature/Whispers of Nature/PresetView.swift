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
    @State private var showingEditPresetSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var newPresetName = ""
    @State private var showAlert = false
    @State private var appliedPresetName = ""
    @State private var presetToDelete: Int?

    init() {
        _presets = State(initialValue: PresetManager.shared.loadPresets())
    }

    var body: some View {
        VStack {
            List {
                ForEach(presets.indices, id: \.self) { index in
                    HStack {
                        Text(presets[index].name)
                            .onTapGesture {
                                // Apply settings when tapping on the name
                                applyPreset(presets[index])
                            }
                        Spacer()
                        Button("Edit") {
                            editingPresetId = presets[index].id
                            newPresetName = presets[index].name
                            showingEditPresetSheet = true
                        }
                        .buttonStyle(BorderlessButtonStyle()) // Ensures the button doesn't capture unwanted touches
                        Spacer().frame(width: 10) // Add some space between buttons
                        Button("Delete") {
                            presetToDelete = index
                            showingDeleteConfirmation = true
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
        }
        .sheet(isPresented: $showingNewPresetSheet) {
            NewPresetView(newPresetName: $newPresetName, onSave: {
                addNewPreset(named: newPresetName)
                showingNewPresetSheet = false
            }, onCancel: {
                showingNewPresetSheet = false
            })
        }
        .sheet(isPresented: $showingEditPresetSheet) {
            EditPresetView(presetName: $newPresetName, onSave: {
                if let index = presets.firstIndex(where: { $0.id == editingPresetId }) {
                    presets[index].name = newPresetName
                    PresetManager.shared.savePresets(presets)
                }
                showingEditPresetSheet = false
            }, onCancel: {
                showingEditPresetSheet = false
            })
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Preset Applied"), message: Text("Applied \(appliedPresetName)"), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Delete Preset"),
                message: Text("Are you sure you want to delete this preset?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let index = presetToDelete {
                        deletePreset(at: index)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func applyPreset(_ preset: AudioPreset) {
        audioVM.waveVolume = preset.waveVolume
        audioVM.treeVolume = preset.treeVolume
        audioVM.fireVolume = preset.fireVolume
        appliedPresetName = preset.name
        showAlert = true
        print("Preset applied: \(preset.name)")  // Debug print
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

struct EditPresetView: View {
    @Binding var presetName: String
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Preset Name", text: $presetName)
                Button("Save Changes") {
                    onSave()
                }
            }
            .navigationBarTitle("Edit Preset", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                onCancel()
            })
        }
    }
}
