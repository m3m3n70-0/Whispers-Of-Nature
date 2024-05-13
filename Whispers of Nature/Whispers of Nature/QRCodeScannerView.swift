import SwiftUI
import AVFoundation

struct QRCodeScannerView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRCodeScannerView
        var captureSession: AVCaptureSession?

        init(parent: QRCodeScannerView, captureSession: AVCaptureSession?) {
            self.parent = parent
            self.captureSession = captureSession
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                captureSession?.stopRunning() // Stop the capture session
                parent.didFindCode(stringValue)
            }
        }

        @objc func handleBackButton() {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    var didFindCode: (String) -> Void
    var didFail: (Error) -> Void
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        let captureSession = AVCaptureSession()
        return Coordinator(parent: self, captureSession: captureSession)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        guard let captureSession = context.coordinator.captureSession else { return viewController }

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            didFail(error)
            return viewController
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            didFail(NSError(domain: "QRCodeScannerView", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to add input"]))
            return viewController
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
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

        // Add a back button with an arrow
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backButton.layer.cornerRadius = 5
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(context.coordinator, action: #selector(Coordinator.handleBackButton), for: .touchUpInside)

        let backButtonContainer = UIView()
        backButtonContainer.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(backButtonContainer)
        backButtonContainer.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButtonContainer.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor),
            backButtonContainer.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            backButtonContainer.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            backButtonContainer.heightAnchor.constraint(equalToConstant: 50),

            backButton.centerXAnchor.constraint(equalTo: backButtonContainer.centerXAnchor),
            backButton.centerYAnchor.constraint(equalTo: backButtonContainer.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        captureSession.startRunning()
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
