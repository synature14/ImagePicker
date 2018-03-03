//
//  AlbumsFlowLayout.swift
//  InstaImagePicker
//
//  Created by sutie on 2018. 2. 28..
//  Copyright © 2018년 sutie. All rights reserved.
//

import UIKit



class AlbumsFlowLayout: UICollectionViewLayout {

    // 1. Layout Delegate
    // weak 키워드를 사용하지 않으면, 메모리 누수가 발생한다 
//    weak var delegate: AlbumsFlowLayoutDelegate!
    
    var numberOfColumns = 2
    var cellSpacing: CGFloat = 6
    
    var cache = [UICollectionViewLayoutAttributes]()
    
    var contentHeight: CGFloat = 0
    var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    /** collectionView가 필요할때마다 content의(width 또는 height가) 길이가 늘어났는지를 물어보는 부분 --> scroll이 가능하게 함
     */
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    
    override func prepare() {
        
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
//            if column >= 1 {
//                xOffset[column] += cellSpacing
//            }
        }
    
        
        var column = 0
        var yOffset = [CGFloat](repeatElement(0, count: numberOfColumns))
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let photoHeight = columnWidth + 30
            let totalHeight = cellSpacing + photoHeight
            
            
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: photoHeight)
            let insetFrame = frame.insetBy(dx: cellSpacing, dy: cellSpacing)
            print("------")
            print(insetFrame)
            
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = insetFrame
            cache.append(attribute)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + totalHeight
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        
        }
    } // prepare()
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        //rect는 사용자가 볼 창의 사이즈
        var visibleAttribute = [UICollectionViewLayoutAttributes]()
        
        // rect범위에 있는 셀들을 불러온다
        for attribute in cache {
            visibleAttribute.append(attribute)
        }
        return visibleAttribute // --> 이제 cellForItem(at:)이 호출됨..!!
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    
}








