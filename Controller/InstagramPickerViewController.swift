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

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bigImageView: UIImageView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var allPhotos: PHFetchResult<PHAsset>!
    let imageManager = PHCachingImageManager()
    var firstAsset: PHAsset!
    
    let screenWidth = UIScreen.main.bounds.size.width
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lightGrayView = UIView(frame: CGRect(x: 0, y: 0, width: bigImageView.bounds.width, height: bigImageView.bounds.height))
        lightGrayView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        containerView.addSubview(lightGrayView)

        scrollView.contentSize = bigImageView.bounds.size
        
        scrollView.minimumZoomScale = 0.4
        scrollView.maximumZoomScale = 4.0
        
        scrollView.frame = CGRect(x: 0, y: 0, width: bigImageView.bounds.size.width, height: bigImageView.bounds.height)
        print("bigImageView.bounds.size.width : \(bigImageView.bounds.size.width)")
        print("bigImageView.bounds.size.width : \(bigImageView.bounds.size.width)")
        
//        scrollView.alwaysBounceVertical = false
//        scrollView.alwaysBounceHorizontal = false
//        scrollView.showsVerticalScrollIndicator = true
//        scrollView.flashScrollIndicators()

        bigImageView.contentMode = .scaleAspectFit
        scrollView.addSubview(bigImageView)
        containerView.addSubview(scrollView)
        
        fetchAllPhotos()
        setBigImage(imageAsset: firstAsset)
    }
    
    // When zoom the image, it would be centered. Just need to update the offset of the image in scrollViewDidZoom()
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let subView = scrollView.subviews[0]    // get the image View
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        
        print("offsetX: \(offsetX), offsetY: \(offsetY)")
        
        // adjust the center of the imageView
        subView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                                  y: scrollView.contentSize.height * 0.5 + offsetY)
        
        
        scrollView.addSubview(subView)
    }
    
    // scrollView delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return bigImageView
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
//            print("\n-----Touches Moved: x = \(pointX), y = \(pointY) -----")
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
        
     // print("screenWidth : \(screenWidth) ---- 2로 나누면? : \(screenWidth/2.0)")
      //  print("** screenHeight : \(UIScreen.main.bounds.height)")
        return CGSize(width: screenWidth/4.0, height: screenWidth/4.0)
    }
}






