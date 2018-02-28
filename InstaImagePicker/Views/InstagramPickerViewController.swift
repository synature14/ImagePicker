//
//  InstagramPickerViewController.swift
//  InstaImagePicker
//
//  Created by sutie on 2018. 2. 27..
//  Copyright © 2018년 sutie. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class InstagramPickerViewController: UIViewController {

    @IBOutlet weak var bigImageView: UIImageView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var allPhotos: PHFetchResult<PHAsset>!
    let imageManager = PHCachingImageManager()
    var firstAsset: PHAsset!
    
    let screenWidth = UIScreen.main.bounds.size.width
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        controller.delegate = self
//        present(controller, animated: true, completion: nil)
        
//        bigImageView.image =
        fetchAllPhotos()
        setBigImage(imageAsset: firstAsset)
        
    }

    func fetchAllPhotos() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        imageCollectionView.reloadData()
        
        // To set the big imageView when view did load
        firstAsset = allPhotos.firstObject
    }
    
    func setBigImage(imageAsset: PHAsset) {
        imageManager.requestImage(for: imageAsset, targetSize: bigImageView.bounds.size,
                                  contentMode: .aspectFit, options: nil,
                                  resultHandler: { image, _ in
                                    self.bigImageView.image = image
        })
    }
    
    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    // when user selects an image
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//
//        bigImageView.image = image
//        dismiss(animated: true, completion: nil)
//    }
    
    // get coordinates of touched location
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: view)
            let pointX = position.x
            let pointY = position.y
            print("---Touch Began: x = \(pointX), y = \(pointY) ----")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: view)
            let pointX = position.x
            let pointY = position.y
            print("\n-----Touches Moved: x = \(pointX), y = \(pointY) -----")
        }
    }
}



extension InstagramPickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("\n사진 개수: \(allPhotos.count)\n")
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PickerCollectionViewCell", for: indexPath) as! PickerCollectionViewCell
        let asset = allPhotos.object(at: indexPath.item)
        
        cell.representedAssetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: screenWidth/4.0, height: screenWidth/4.0),
                                  contentMode: .aspectFit, options: nil,
                                  resultHandler: { image, _ in
                                    if cell.representedAssetIdentifier == asset.localIdentifier {
                                        cell.updateWithImage(image: image)
                                    }
        })
        return cell
    }
    
}

extension InstagramPickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAsset = allPhotos.object(at: indexPath.item)
        setBigImage(imageAsset: selectedAsset)
    }
}

extension InstagramPickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        print("screenWidth : \(screenWidth) ---- 4로 나누면? : \(screenWidth/4.0)")
        return CGSize(width: screenWidth/4.0, height: screenWidth/4.0)
    }
}






