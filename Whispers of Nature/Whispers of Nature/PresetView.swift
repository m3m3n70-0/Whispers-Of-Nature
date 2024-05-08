import SwiftUI
import AVFoundation

struct AudioPreset: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var waveVolume: Float
    var treeVolume: Float
    var fireVolume: Float
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

struct QRCodeScannerView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRCodeScannerView
        
        init(parent: QRCodeScannerView) {
            self.parent = parent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                parent.didFindCode(stringValue)
            }
        }
    }

    var didFindCode: (String) -> Void
    var didFail: (Error) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            didFail(error)
            return viewController
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            didFail(NSError(domain: "QRCodeScannerView", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to add input"]))
            return viewController
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            didFail(NSError(domain: "QRCodeScannerView", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to add output"]))
            return viewController
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
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
            VStack {
                List {
                    ForEach(presets.indices, id: \.self) { index in
                        HStack {
                            Text(presets[index].name)
                                .onTapGesture {
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
                    Button("Scan QR Code") {
                        showingScanner = true
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
        // Assuming the QR code contains JSON data for the preset
        if let data = code.data(using: .utf8),
           let preset = try? JSONDecoder().decode(AudioPreset.self, from: data) {
            presets.append(preset)
            PresetManager.shared.savePresets(presets)
            showAlertType = .apply
            appliedPresetName = preset.name
        } else {
            print("Failed to decode preset from QR code")
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
