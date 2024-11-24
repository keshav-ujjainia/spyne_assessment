//
//  ImageTableViewCell.swift
//  CaptureIt
//
//  Created by krill on 23/11/24.
//

import UIKit
import RealmSwift

class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var imageDetail: CapturedImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with imageDetail: CapturedImage) {
        self.imageDetail = imageDetail
        
        // Set the thumbnail image
        if let imageData = imageDetail.imageData, let image = UIImage(data: imageData) {
            thumbnailImageView.image = image
        } else {
            thumbnailImageView.image = UIImage(systemName: "photo") // Placeholder
        }
        
        // Set the name label
        nameLabel.text = imageDetail.imageName
        
        // Set the date label
        dateLabel.text = "Captured: \(formatDate(imageDetail.captureDate))"
        
        // Set the status label
        statusLabel.text = "Status: \(imageDetail.uploadStatus)"
        
        // Update the progress bar
        progressBar.progress = imageDetail.progress
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // This method will be used to update the progress bar, save progress in Realm and set the upload status
    func updateProgressBar(_ progress: Float) {
        // Update the progress bar animation
        progressBar.setProgress(progress, animated: true)
        
    }
}
