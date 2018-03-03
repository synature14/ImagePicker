//
//  AlbumsCollectionViewCell.swift
//  InstaImagePicker
//
//  Created by sutie on 2018. 2. 28..
//  Copyright © 2018년 sutie. All rights reserved.
//

import UIKit
import PhotosUI
import Photos

class STAlbumsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    
    let imageManager = PHCachingImageManager()
    
    var album: Album? {
        didSet {
            if let album = album {
                let imageSize: CGSize = imageView.bounds.size
                
                guard let imageAsset = album.imageAsset else{
                    return 
                }
                
                imageManager.requestImage(for: imageAsset, targetSize: imageSize,
                                          contentMode: .aspectFit, options: nil,
                                          resultHandler: { image, _ in
                                            self.imageView.image = image
                })

                albumTitleLabel.text = album.title
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true
    }

}
