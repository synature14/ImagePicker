//
//  PickerCollectionViewCell.swift
//  InstaImagePicker
//
//  Created by sutie on 2018. 2. 27..
//  Copyright © 2018년 sutie. All rights reserved.
//

import UIKit

class STPickerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var smallImageView: UIImageView!
    
    var representedAssetIdentifier: String!
    
    func updateWithImage(image: UIImage?) {
        if let imageToDisplay = image {
            smallImageView.image = imageToDisplay
        }
        else {
            smallImageView.image = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateWithImage(image: nil)
    }
    
    func lengthenCellHeight() {
        
    }
}
