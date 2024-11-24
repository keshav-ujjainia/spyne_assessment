//
//  RealmManager.swift
//  CaptureIt
//
//  Created by krill on 23/11/24.
//

import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    
    private var realm: Realm
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Could not initialize Realm: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Saving Captured Image
    func saveCapturedImage(_ image: CapturedImage) {
        do {
            try realm.write {
                realm.add(image, update: .modified)  // Add or update image in the database
            }
        } catch {
            print("Error saving captured image: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Retrieving All Captured Images
    func getAllCapturedImages() -> [CapturedImage] {
        let images = realm.objects(CapturedImage.self)
        return Array(images)
    }
    
    // MARK: - Retrieving Image by ID
    func getCapturedImageById(_ id: String) -> CapturedImage? {
        return realm.object(ofType: CapturedImage.self, forPrimaryKey: id)
    }
    
    // MARK: - Updating Captured Image
    func updateCapturedImageProgress(_ id: String, progress: Float) {
        if let imageToUpdate = getCapturedImageById(id) {
            do {
                try realm.write {
                    imageToUpdate.progress = progress
                    imageToUpdate.uploadStatus = progress == 1.0 ? "Completed" : "Uploading"
                }
            } catch {
                print("Error updating image progress: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Updating Upload Status Based on Progress
    func updateUploadStatus(_ id: String, progress: Float) {
        if let imageToUpdate = getCapturedImageById(id) {
            let uploadStatus: String
            if progress == 0 {
                uploadStatus = "Pending"
            } else if progress > 0 && progress < 1 {
                uploadStatus = "Uploading"
            } else if progress == 1 {
                uploadStatus = "Completed"
            } else {
                uploadStatus = "Unknown"
            }
            
            do {
                try realm.write {
                    imageToUpdate.uploadStatus = uploadStatus
                    imageToUpdate.progress = progress
                }
            } catch {
                print("Error updating upload status: \(error.localizedDescription)")
            }
        }
    }
}
