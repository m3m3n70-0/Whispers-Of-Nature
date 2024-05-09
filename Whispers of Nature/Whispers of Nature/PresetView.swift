import SwiftUI

struct AudioPreset: Identifiable, Codable {
    var id: UUID
    var name: String
    var waveVolume: Float
    var treeVolume: Float
    var fireVolume: Float
    
    init(id: UUID = UUID(), name: String, waveVolume: Float, treeVolume: Float, fireVolume: Float) {
        self.id = id
        self.name = name
        self.waveVolume = waveVolume
        self.treeVolume = treeVolume
        self.fireVolume = fireVolume
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case waveVolume
        case treeVolume
        case fireVolume
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.waveVolume = try container.decode(Float.self, forKey: .waveVolume)
        self.treeVolume = try container.decode(Float.self, forKey: .treeVolume)
        self.fireVolume = try container.decode(Float.self, forKey: .fireVolume)
    }
}

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

enum AlertType: Identifiable {
    case apply
    case delete

    var id: Int {
        hashValue
    }
}

struct PresetsView: View {
    @EnvironmentObject var audioVM: AudioViewModel
    @State private var presets: [AudioPreset] = []
    @State private var editingPresetId: UUID?
    @State private var showingNewPresetSheet = false
    @State private var showingEditPresetSheet = false
    @State private var showingScanner = false
    @State private var newPresetName = ""
    @State private var showAlertType: AlertType?
    @State private var appliedPresetName = ""
    @State private var presetToDelete: AudioPreset?

    init() {
        _presets = State(initialValue: PresetManager.shared.loadPresets())
    }

    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                VStack {
                    List {
                        ForEach(presets.indices, id: \.self) { index in
                            HStack {
                                Text(presets[index].name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.leading, 10)
                                    .onTapGesture {
                                        applyPreset(presets[index])
                                    }
                                Spacer()
                                HStack(spacing: 10) {
                                    Button(action: {
                                        editingPresetId = presets[index].id
                                        newPresetName = presets[index].name
                                        showingEditPresetSheet = true
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.green.opacity(0.7))
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(BorderlessButtonStyle())

                                    Button(action: {
                                        presetToDelete = presets[index]
                                        showAlertType = .delete
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.red.opacity(0.7))
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(10)
                        }
                        .listRowBackground(Color.clear)
                        
                        Button(action: {
                            showingNewPresetSheet = true
                            newPresetName = "" // Reset the name field for new entry
                        }) {
                            Text("Add New Preset")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.8))
                                .cornerRadius(10)
                        }
                        .padding(.top)
                        
                        Button(action: {
                            showingScanner = true
                        }) {
                            Text("Scan QR Code")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.8))
                                .cornerRadius(10)
                        }
                    }
                    .listStyle(PlainListStyle())
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
                    .sheet(isPresented: $showingScanner) {
                        QRCodeScannerView(didFindCode: { code in
                            handleScannedCode(code)
                            showingScanner = false
                        }, didFail: { error in
                            print("Scanning failed: \(error.localizedDescription)")
                            showingScanner = false
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
                .padding()
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

    private func handleScannedCode(_ code: String) {
        print("Scanned code: \(code)") // Debug print to see the scanned code
        // Assuming the QR code contains JSON data for the preset
        if let data = code.data(using: .utf8) {
            do {
                let preset = try JSONDecoder().decode(AudioPreset.self, from: data)
                presets.append(preset)
                PresetManager.shared.savePresets(presets)
                showAlertType = .apply
                appliedPresetName = preset.name
            } catch {
                print("Failed to decode preset from QR code: \(error)") // More detailed error message
            }
        } else {
            print("Failed to convert code to data")
        }
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
