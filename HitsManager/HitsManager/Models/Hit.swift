//
//  Hit.swift
//  HitsManager
//
//  Created by LTT on 11/2/20.
//

import Foundation
import UIKit

struct Hit: Decodable, Hashable {
    var imageId: Int
    var imageURL: String
    var imageWidth: CGFloat
    var imageHeight: CGFloat
    var autherImageUrl: String
    var autherName: String
    
    enum CodingKeys: String, CodingKey {
        case imageId = "id"
        case imageURL = "largeImageURL"
        case imageWidth = "imageWidth"
        case imageHeight = "imageHeight"
        case autherImageUrl = "userImageURL"
        case autherName = "user"
    }
    
    init(id: Int, imageUrl: String,
         imageWidth: CGFloat,
         imageHeight: CGFloat,
         userImageUrl: String,
         username: String) {
        self.imageId = id
        self.imageURL = imageUrl
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.autherImageUrl = userImageUrl
        self.autherName = username
    }
    
    init() {
        imageId = 0
        imageURL = ""
        imageWidth = 0
        imageHeight = 0
        autherImageUrl = ""
        autherName = ""
    }
    
    func asDidLikeHit() -> DidLikeHit {
        let didLikeHit = DidLikeHit()
        didLikeHit.id = imageId
        didLikeHit.url = imageURL
        didLikeHit.imageWidth = Float(imageWidth)
        didLikeHit.imageHeight = Float(imageHeight)
        didLikeHit.autherImageUrl = autherImageUrl
        didLikeHit.autherName = autherName
        return didLikeHit
    }
}
