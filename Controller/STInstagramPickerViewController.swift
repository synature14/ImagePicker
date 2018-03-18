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


protocol ImagePickerDelegate: class {
    func imagePickerDidCancel(_ imagePicker: STInstagramPickerViewController)
    func imagePickerDidDone(_ imagePicker: STInstagramPickerViewController, image: UIImage?)
}



class STInstagramPickerViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bigImageView: UIImageView!
    @IBOutlet weak var imageCollectionView: UICollectionView!

    weak var delegate: ImagePickerDelegate?
    
    
    @IBAction func cancleButton(_ sender: Any) {
        delegate?.imagePickerDidCancel(self)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        let originContentXOffset = scrollView.contentOffset.x / scrollView.zoomScale
        let originContentYOffset = scrollView.contentOffset.y / scrollView.zoomScale
        
        let selectedRect = CGRect(x: originContentXOffset,
                                  y: originContentYOffset,
                                  width: bigImageView.bounds.size.width,
                                  height: bigImageView.bounds.size.height)
        
        if let cutImage = bigImageView.image?.cgImage?.cropping(to: selectedRect) {
            let image = UIImage(cgImage: cutImage)
            delegate?.imagePickerDidDone(self, image: image)
        } else {
            delegate?.imagePickerDidDone(self, image: nil)      // 이미지 처리 실패
        }
        
        
    }
    
    
    var allPhotos: PHFetchResult<PHAsset>!
    let imageManager = PHCachingImageManager()
    var firstAsset: PHAsset!
    
    let screenWidth = UIScreen.main.bounds.size.width
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let constraint = NSLayoutConstraint(item: containerView,
//                                            attribute: NSLayoutAttribute.top,
//                                            relatedBy: NSLayoutRelation.equal, toItem: self.view,
//                                            attribute: NSLayoutAttribute.top,
//                                            multiplier: 1,
//                                            constant: 0.0).isActive = true
        
        
        scrollView.layer.borderWidth = 18
        scrollView.layer.borderColor? = UIColor.black.withAlphaComponent(0.3).cgColor
        
        scrollView.contentSize = bigImageView.bounds.size
        
        scrollView.minimumZoomScale = 1.3
        scrollView.maximumZoomScale = 4.0
        
        scrollView.zoomScale = 2.0
        scrollView.contentMode = .scaleAspectFill
        scrollView.frame = CGRect(x: 0, y: 0, width: bigImageView.bounds.size.width, height: bigImageView.bounds.height)
        print("bigImageView.bounds.size.width : \(bigImageView.bounds.size.width)")
        print("bigImageView.bounds.size.height : \(bigImageView.bounds.size.height)")
        
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        
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
                                    self.bigImageView.contentMode = .scaleAspectFill
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
            print("\n--Touches Moved: imageCollectionView.frame.minY = \(imageCollectionView.frame.minY), y = \(pointY) ---")
            
            // if the user touch the collectionView and move it up to bigImageView,
            if pointY < imageCollectionView.frame.minY{
                containerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -50).isActive = true
                
//                let contraint = NSLayoutConstraint(item: bigImageView, attribute: NSLayoutAttribute.top,
//                                                           relatedBy: NSLayoutRelation.equal,
//                                                           toItem: containerView,
//                                                           attribute: NSLayoutAttribute.bottom,
//                                                           multiplier: 1,
//                                                           constant: -45.0).isActive = true
            }
        }
    }
}


extension STInstagramPickerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}



extension STInstagramPickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("\n사진 개수: \(allPhotos.count)\n")
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PickerCollectionViewCell", for: indexPath) as! STPickerCollectionViewCell
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

extension STInstagramPickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAsset = allPhotos.object(at: indexPath.item)
        setBigImage(imageAsset: selectedAsset)
    }
}

extension STInstagramPickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
     // print("screenWidth : \(screenWidth) ---- 2로 나누면? : \(screenWidth/2.0)")
      //  print("** screenHeight : \(UIScreen.main.bounds.height)")
        return CGSize(width: screenWidth/4.0, height: screenWidth/4.0)
    }
}






