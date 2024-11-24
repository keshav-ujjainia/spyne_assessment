//
//  UploadManager.swift
//  CaptureIt
//
//  Created by krill on 23/11/24.
//
import Foundation
import RealmSwift

class ApiManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    static let shared = ApiManager()
    
    private var uploadProgressCallback: ((Float) -> Void)?
    
    func uploadImage(_ imageData: Data, for image: CapturedImage, progress: @escaping (Float) -> Void, completion: @escaping (Bool, String) -> Void) {
        let url = URL(string: "https://www.clippr.ai/api/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(image.imageName)\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        request.httpBody = body
        
        self.uploadProgressCallback = progress
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        
        let task = session.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                print("Error during upload: \(error.localizedDescription)")
                completion(false, "Upload failed: \(error.localizedDescription)")
                self.updateStatus(for: image, status: "Failed", progress: 0.0)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("Upload successful!")
                    completion(true, "Upload successful.")
                    //                    self.updateStatus(for: image, status: "Completed", progress: 1.0)
                } else {
                    print("Upload failed with status code: \(httpResponse.statusCode)")
                    completion(false, "Upload failed with status code: \(httpResponse.statusCode)")
                    //                    self.updateStatus(for: image, status: "Failed", progress: 0.0)
                }
            }
        }
        
        task.resume()
    }
    
    // URLSession delegate method for tracking upload progress
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        uploadProgressCallback?(progress)  // Call the callback with progress
        print("Upload progress: \(progress * 100)%")
    }
    
    private func updateStatus(for image: CapturedImage, status: String, progress: Float) {
        DispatchQueue.global(qos: .background).async {
            let realm = try! Realm()
            try! realm.write {
                if let imageToUpdate = realm.objects(CapturedImage.self).filter("id = %@", image.id).first {
                    imageToUpdate.uploadStatus = status
                    imageToUpdate.progress = progress
                }
            }
        }
    }
    
}


extension Data {
    func isJPEG() -> Bool {
        let bytes = [UInt8](self.prefix(4))
        return bytes == [0xFF, 0xD8, 0xFF, 0xE0] || bytes == [0xFF, 0xD8, 0xFF, 0xE1]
    }
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
