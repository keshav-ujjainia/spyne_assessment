//
//  CapturedImage.swift
//  CaptureIt
//
//  Created by krill on 23/11/24.
//

import RealmSwift
import UIKit

class CapturedImage: Object {
    @Persisted var id: String = UUID().uuidString
    @Persisted var imageData: Data?
    @Persisted var imageName: String = ""
    @Persisted var captureDate: Date = Date()
    @Persisted var uploadStatus: String = "Pending"
    @Persisted var progress: Float = 0.0  // Add this property
    @Persisted var imageURI: String?  // URI after upload (optional)
    
    override static func primaryKey() -> String? {
            return "id" // The field used as the primary key
        }

    convenience init(image: UIImage, imageName: String) {
        self.init()
        self.imageName = imageName
        self.imageData = image.jpegData(compressionQuality: 0.8)!
    }
}


