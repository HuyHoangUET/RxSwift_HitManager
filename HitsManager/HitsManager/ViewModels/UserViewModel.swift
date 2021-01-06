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
import RxRealm
import RealmSwift

class UserViewModel {
    var isDisplayCellAtChosenIndexPath = true
    let chosenIndexPathSubject = BehaviorSubject<IndexPath>(value: IndexPath())
    var chosenIndexPath: Observable<IndexPath> {
        return chosenIndexPathSubject.asObserver()
    }
    var didLikeHitsRelay = BehaviorRelay<[Hit]>(value: [])
    var didDislikeImagesId: Set<Int> = []
    private let bag = DisposeBag()
    var isDatabaseChange = false
    
    func updateDidLikeHits() {
        do {
            var hits: [Hit] = []
            let realm = try Realm()
            let didLikeHits = realm.objects(DidLikeHit.self)
            Observable.arrayWithChangeset(from: didLikeHits)
                .subscribe(onNext: { array, changes in
                    let newDidLikeHits: [DidLikeHit] = array
                    for didLikeHit in newDidLikeHits {
                        let hit = Hit(id: didLikeHit.id,
                                      imageUrl: didLikeHit.url,
                                      imageWidth: CGFloat(didLikeHit.imageWidth),
                                      imageHeight: CGFloat(didLikeHit.imageHeight),
                                      userImageUrl: didLikeHit.userImageUrl,
                                      username: didLikeHit.username)
                        hits.append(hit)
                    }
                    if changes != nil {
                        self.isDatabaseChange = true
                    }
                })
                .disposed(by: bag)
            var value = self.didLikeHitsRelay.value
            value.append(contentsOf: hits)
            self.didLikeHitsRelay.accept(hits)
        } catch {
            return
        }
    }
}
