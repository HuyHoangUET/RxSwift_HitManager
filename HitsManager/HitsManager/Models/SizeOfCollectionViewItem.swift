//
//  Size.swift
//  HitsManager
//
//  Created by LTT on 19/11/2020.
//

import Foundation
import UIKit

struct SizeOfCollectionViewItem {
    private static let numberOfItemsInRow = 3
    private static let paddingSpace: CGFloat = 12
    private static let screenWidth = UIScreen.main.bounds.width

     static func getCellWidth() -> CGFloat {
        let cellWidth = screenWidth - (paddingSpace/CGFloat(numberOfItemsInRow - 1))
        return cellWidth
    }
    
    static func getInsetOfSection() -> UIEdgeInsets {
        let insetOfSection = UIEdgeInsets(top: 3,
                                          left: paddingSpace/CGFloat(numberOfItemsInRow + 1),
                                          bottom: 10, right: paddingSpace/CGFloat(numberOfItemsInRow + 1))
        return insetOfSection
    }
    
    static func getItemsWidth() -> CGFloat {
        let itemsWidth = screenWidth - paddingSpace
        return itemsWidth
    }
    
    static func getSizeForItem() -> CGSize {
        let itemsWidth = getItemsWidth()
        let sizeForItem = CGSize(width: itemsWidth/CGFloat(numberOfItemsInRow),
                             height: itemsWidth/CGFloat(numberOfItemsInRow))
        return sizeForItem
    }
    
    static func getSizeForDidSellectItem(imageWidth: CGFloat, imageHeight: CGFloat) -> CGSize {
        let cellWidth = getCellWidth()
        let cellHeight = cellWidth * (imageHeight / imageWidth)
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    static func getMinimumInteritemSpacingForSection() -> CGFloat {
        let minimumInteritemSpacingForSection = paddingSpace/CGFloat(numberOfItemsInRow + 1)
        return minimumInteritemSpacingForSection
    }
    
    static func getMinimumLineSpacingForSection() -> CGFloat {
        let minimumLineSpacingForSection = paddingSpace/CGFloat(numberOfItemsInRow + 1)
        return minimumLineSpacingForSection
    }
}
