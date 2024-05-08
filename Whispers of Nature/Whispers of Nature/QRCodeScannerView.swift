//import Foundation
//import SwiftUI
//import AVFoundation
//
//struct QRCodeScannerView: UIViewControllerRepresentable {
//    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
//        var parent: QRCodeScannerView
//        
//        init(parent: QRCodeScannerView) {
//            self.parent = parent
//        }
//        
//        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//            if let metadataObject = metadataObjects.first {
//                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
//                guard let stringValue = readableObject.stringValue else { return }
//                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//                parent.didFindCode(stringValue)
//            }
//        }
//    }
//
//    var didFindCode: (String) -> Void
//    var didFail: (Error) -> Void
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(parent: self)
//    }
//
//    func makeUIViewController(context: Context) -> UIViewController {
//        let viewController = UIViewController()
//        let captureSession = AVCaptureSession()
//
//        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
//        let videoInput: AVCaptureDeviceInput
//
//        do {
//            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
//        } catch {
//            didFail(error)
//            return viewController
//        }
//
//        if (captureSession.canAddInput(videoInput)) {
//            captureSession.addInput(videoInput)
//        } else {
//            didFail(NSError(domain: "QRCodeScannerView", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to add input"]))
//            return viewController
//        }
//
//        let metadataOutput = AVCaptureMetadataOutput()
//
//        if (captureSession.canAddOutput(metadataOutput)) {
//            captureSession.addOutput(metadataOutput)
//
//            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
//            metadataOutput.metadataObjectTypes = [.qr]
//        } else {
//            didFail(NSError(domain: "QRCodeScannerView", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to add output"]))
//            return viewController
//        }
//
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.frame = viewController.view.layer.bounds
//        previewLayer.videoGravity = .resizeAspectFill
//        viewController.view.layer.addSublayer(previewLayer)
//
//        captureSession.startRunning()
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
//}
