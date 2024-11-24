//
//  CameraViewModel.swift
//  CaptureIt
//
//  Created by krill on 23/11/24.
//

import Foundation
import UIKit

class CameraViewModel: ObservableObject {
    @Published var capturedImages: [UIImage] = []
    func captureImage(image: UIImage) {
        capturedImages.append(image)
        saveImageToRealm(image: image)
    }
    private func saveImageToRealm(image: UIImage) {
        // Save image metadata to Realm
    }
}
