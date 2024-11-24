//
//  ViewController.swift
//  CaptureIt
//
//  Created by krill on 23/11/24.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var ImageTableView: UITableView!
    
    var imagesWithDetails  = [CapturedImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Example Usage
        setupCameraButton()
        setupResumeButton()
        ImageTableView.delegate = self
        ImageTableView.dataSource = self
        reloadData()
        self.title = "Spyne"
    }
    
    private func setupCameraButton() {
        // Create the camera button with a system image
        let cameraButton = UIBarButtonItem(
            image: UIImage(systemName: "camera.fill"), // Using SF Symbol for camera icon
            style: .plain,
            target: self,
            action: #selector(cameraButtonTapped)
        )
        
        // Set the camera button to the right of the navigation bar
        navigationItem.rightBarButtonItem = cameraButton
    }
    
    
    
    // Action when the camera button is tapped
    @objc private func cameraButtonTapped() {
        print("Camera button tapped")
        // Call your method to open the camera here
        openCamera()
    }
    
    private func setupResumeButton() {
        // Create the camera button with a system image
        let resumeButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"), // Using SF Symbol for camera icon
            style: .plain,
            target: self,
            action: #selector(resumeButtonTapped)
        )
        
        // Set the camera button to the right of the navigation bar
        navigationItem.leftBarButtonItem = resumeButton
    }
    
    @objc private func resumeButtonTapped() {
        print("Resume button tapped")
        // Call your method to open the camera here
        resumeUploads()
    }
    
    
    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            self?.imagesWithDetails = RealmManager.shared.getAllCapturedImages().reversed()
            self?.ImageTableView.reloadData()
        }
    }
    
    func resumeUploads(){
        DispatchQueue.main.async {
            self.title = "Resuming pending uploads"
        }
        for item in self.imagesWithDetails {
            if item.uploadStatus != "Completed"{
                self.uploadImage(imageData: item.imageData!, for: item)
            }
        }
        
        DispatchQueue.main.async {
            self.title = "All images are uploaded"
        }
    }
    
    func openCamera() {
        CameraManager.shared.checkAuthorizationAndOpenCamera(from: self) { capturedImage in
            if let image = capturedImage {
                print("Image Captured: \(image)")
                let imageName = "IMG_\(Int(Date().timeIntervalSince1970)).jpg"
                
                // Convert UIImage to CapturedImage and save to Realm
                let capturedImageModel = CapturedImage(image: image, imageName: imageName)
                RealmManager.shared.saveCapturedImage(capturedImageModel) // Pass the CapturedImage model
                
                self.reloadData()
                
                // Convert UIImage to JPEG data for upload
                let imgData = image.jpegData(compressionQuality: 0.8)!
                self.uploadImage(imageData: imgData, for: capturedImageModel)
            } else {
                print("Camera access denied or operation cancelled.")
            }
        }
    }
    
    func uploadImage(imageData: Data, for image: CapturedImage) {
        ApiManager.shared.uploadImage(imageData, for: image, progress: { [weak self] progress in
            // Ensure we're on the main thread since UI updates need to be on the main thread
            DispatchQueue.main.async {
                if let index = self?.imagesWithDetails.firstIndex(where: { $0.id == image.id }) {
                    // Get the cell corresponding to the image
                    if let cell = self?.ImageTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ImageTableViewCell {
                        // Update the progress bar on the cell
                        print(progress)
                        cell.updateProgressBar(progress)
                        RealmManager.shared.updateCapturedImageProgress(image.id, progress: progress)
                        RealmManager.shared.updateUploadStatus(image.id, progress: progress)
                        self?.reloadData()
                    }
                }
            }
        }, completion: { success, message in
            DispatchQueue.main.async {
                print(message)
                if success {
                    // Update image status or perform other actions upon completion
                    RealmManager.shared.updateUploadStatus(image.id, progress: 1.0)
                } else {
                    // Handle failure
                    RealmManager.shared.updateUploadStatus(image.id, progress: 0.0)
                }
            }
        })
    }
    
    
    
    // Save Image to Realm
    private func saveImageToRealm(_ capturedImage: CapturedImage) {
        let realm = try! Realm() // Use RealmSwift's Realm instance
        
        try! realm.write {
            realm.add(capturedImage)
        }
        
        print("Image saved to Realm with ID: \(capturedImage.id), Name: \(capturedImage.imageName)")
    }
    
    func fetchImagesWithDetails() -> Results<CapturedImage> {
        let realm = try! Realm() // Use RealmSwift's Realm instance
        // Fetch images with pending status
        let predicate = NSPredicate(format: "uploadStatus == %@", "Pending")
        return realm.objects(CapturedImage.self).filter(predicate)
    }
    
    func updateImageUploadStatus(imageID: String, newStatus: String, newURI: String?) {
        let realm = try! Realm() // Use RealmSwift's Realm instance
        let results = realm.objects(CapturedImage.self).filter("id = %@", imageID)
        
        if let imageToUpdate = results.first {
            // Begin a write transaction
            try! realm.write {
                imageToUpdate.uploadStatus = newStatus
                imageToUpdate.imageURI = newURI
            }
            
            print("Updated image \(imageID): Status = \(newStatus), URI = \(newURI ?? "No URI")")
        } else {
            print("Image with ID \(imageID) not found in Realm.")
        }
    }
}




extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return imagesWithDetails.count
    }
    
    // MARK: - UI Elements
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageTableViewCell
        let imageDetail = imagesWithDetails[indexPath.row]
        cell.configure(with: imageDetail)
        return cell
    }
}
