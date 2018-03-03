//
//  Album.swift
//  InstaImagePicker
//
//  Created by sutie on 2018. 2. 28..
//  Copyright © 2018년 sutie. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

struct STAlbum {
    var imageAsset: PHAsset?
    var title: String
    
    init(imageAsset: PHAsset?, title: String){
        self.imageAsset = imageAsset
        self.title = title
    }
    
    static func allAlbums() -> [Album] {
        let albums = [Album]()
        
        return albums
    }
}
