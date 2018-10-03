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
    
    
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBAction func cancleButton(_ sender: Any) {
        delegate?.imagePickerDidCancel(self)
    }
    
    
    private func setImageToPreview(_ image: UIImage) {
        let widthScale = scrollView.frame.size.width / image.size.width
        let heightScale = scrollView.frame.size.height / image.size.height
        let minScale = min(widthScale, heightScale)
        let maxScale = max(widthScale, heightScale)
        
        print("minScale: \(minScale) maxScale: \(maxScale), imageSize: \(image.size)")
        
        imageViewWidthConstraint.constant = image.size.width
        imageViewHeightConstraint.constant = image.size.height
        
        DispatchQueue.main.async { [weak self] in
            self?.scrollView.minimumZoomScale = minScale
            self?.scrollView.setZoomScale(maxScale, animated: true)
            self?.bigImageView.image = image
        }
    }
    
    
    @IBAction func doneButton(_ sender: Any) {
        print("scrollView.zoomScale : \(scrollView.zoomScale)")
    
        let croppedImage = cropZoomedImage()
        delegate?.imagePickerDidDone(self, image: croppedImage)
    }
    
    
    private func cropZoomedImage() -> UIImage? {
        let reverseScale = 1 / scrollView.zoomScale
        
        let xOffset = scrollView.contentOffset.x * reverseScale
        let yOffset = scrollView.contentOffset.y * reverseScale
        
        let adjustedWidth = scrollView.bounds.width * reverseScale
        let adjustedHeight = scrollView.bounds.height * reverseScale
        
        let origin = CGPoint(x: xOffset, y: yOffset)
        let size = CGSize(width: adjustedWidth, height: adjustedHeight)
        
        if let cgZoomedImage = bigImageView.image?.cgImage?.cropping(to: CGRect(origin: origin, size: size)) {
            return UIImage(cgImage: cgZoomedImage)
        } else {
            return nil
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
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        
        scrollView.zoomScale = 1.0
        scrollView.contentMode = .scaleAspectFill
        scrollView.frame = CGRect(x: 0, y: 0, width: bigImageView.bounds.size.width, height: bigImageView.bounds.size.height)
       
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
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        imageManager.requestImage(for: imageAsset, targetSize: scrollView.bounds.size,
                                  contentMode: .aspectFill, options: options,
                                  resultHandler: { image, _ in
                                    guard let image = image else { return }
                                    self.bigImageView.image = image
        })
    }
    
    
    // get coordinates of touched location
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: view)
            let pointX = position.x
            let pointY = position.y
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: view)
            let pointX = position.x
            let pointY = position.y

            // if the user touch the collectionView and move it up to bigImageView,
            if pointY < imageCollectionView.frame.minY {
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
        print("*** scrollView.contentSize.width ----> \(scrollView.contentSize.width)")
        print("*** scrollView.contentSize.HEIGHT ---> \(scrollView.contentSize.height)\n")
    }
}



extension STInstagramPickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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






