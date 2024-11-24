//
//  CameraManager.swift
//  CaptureIt
//
//  Created by krill on 23/11/24.
//

import UIKit
import Photos

class CameraManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    static let shared = CameraManager()
    
    private var captureCompletion: ((UIImage?) -> Void)?
    
    private override init() {}
    
    // MARK: - Check Authorization and Open Camera
    func checkAuthorizationAndOpenCamera(from viewController: UIViewController, completion: @escaping (UIImage?) -> Void) {
        self.captureCompletion = completion
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            self.presentCameraInterface(from: viewController)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.presentCameraInterface(from: viewController)
                    } else {
                        completion(nil)
                    }
                }
            }
        default:
            completion(nil)
        }
    }
    
    // MARK: - Present Camera Interface
    private func presentCameraInterface(from viewController: UIViewController) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let pickerController = UIImagePickerController()
            pickerController.sourceType = .camera
            pickerController.delegate = self
            pickerController.modalPresentationStyle = .fullScreen
            
            viewController.present(pickerController, animated: true, completion: nil)
        } else {
            print("Camera is not available on this device.")
            captureCompletion?(nil)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[.originalImage] as? UIImage {
            captureCompletion?(image)
        } else {
            captureCompletion?(nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        captureCompletion?(nil)
    }
}
