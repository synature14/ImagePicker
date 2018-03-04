//
//  AlbumsViewController.swift
//  InstaImagePicker
//
//  Created by sutie on 2018. 2. 28..
//  Copyright © 2018년 sutie. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class STAlbumsViewController: UICollectionViewController {

    var albums = STAlbum.allAlbums()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 30, left: 6, bottom: 5, right: 6)
        
        // Set the PinterestLayout delegate
        if let layout = collectionView?.collectionViewLayout as? STAlbumsFlowLayout {
            layout.cellSpacing = 10
        }

        setupPhotos()
        collectionView?.contentOffset = CGPoint(x: 0, y: 0)
        collectionView?.reloadData()
    }

    
    func setupPhotos() {
        let fetchOptions = PHFetchOptions()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                  subtype: .albumRegular,
                                                                  options: fetchOptions)
        var countTheNumberOfAlbum: Int = 1
        
        smartAlbums.enumerateObjects( { (asset, index, stop) -> Void in
            
            guard countTheNumberOfAlbum < index else {
                return
            }
            
            print("\n---countTheNumberOfAlbum : \(countTheNumberOfAlbum)번째---")
            countTheNumberOfAlbum += 1
            
            let assetCollection = asset
            print("albums title: \(assetCollection.localizedTitle)")
        
            let assetsFetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
            let numberOfAssets = assetsFetchResult.count
            print("numberOfAssets ==== \(numberOfAssets)  개")
            
            var sample: STAlbum
            
            if let firstObject = assetsFetchResult.firstObject {
                sample = STAlbum(imageAsset: firstObject, title: assetCollection.localizedTitle!)
            }
            else {
                sample = STAlbum(imageAsset: nil, title: assetCollection.localizedTitle!)
            }
            
            self.albums.append(sample)
        })
    } // setupPhotos()
}


extension STAlbumsViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as! STAlbumsCollectionViewCell
        cell.album = self.albums[indexPath.item]
        print("indexPath item --->> \(indexPath.item)")
        
        return cell
    }
}






