//
//  UserViewModel.swift
//  HitsManager
//
//  Created by LTT on 19/11/2020.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class UserViewModel {
    var isDisplayCellAtChosenIndexPath = true
    let chosenIndexPathSubject = BehaviorSubject<IndexPath>(value: IndexPath())
    var chosenIndexPath: Observable<IndexPath> {
        return chosenIndexPathSubject.asObserver()
    }
    var didLikeHits: [Hit] = []
    var didLikeHitsRelay = BehaviorRelay<[Hit]>(value: [])
    
    func getDidLikeHit(didLikeHits: [DidLikeHit]) -> [Hit] {
        var hits: [Hit] = []
        for didLikeHit in didLikeHits {
            let hit = Hit(id: didLikeHit.id,
                          imageUrl: didLikeHit.url,
                          imageWidth: CGFloat(didLikeHit.imageWidth),
                          imageHeight: CGFloat(didLikeHit.imageHeight),
                          userImageUrl: didLikeHit.userImageUrl,
                          username: didLikeHit.username)
            hits.append(hit)
        }
        return hits
    }
}
