//
//  DidLikeImage.swift
//  HitsManager
//
//  Created by LTT on 17/11/2020.
//

import Foundation
import RealmSwift
import RxCocoa
import RxSwift
import RxRealm

class DidLikeHit: Object {
    @objc dynamic var id = 0
    @objc dynamic var url = ""
    @objc dynamic var imageWidth: Float = 0
    @objc dynamic var imageHeight: Float = 0
    @objc dynamic var userImageUrl = ""
    @objc dynamic var username = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    static func addAnObject(hit: Hit) {
        do {
            let realm = try Realm()
            let didLikeImage = convertToDidLikeHit(hit: hit)
            Observable.from(object: didLikeImage)
                .subscribe(realm.rx.add())
                .disposed(by: DisposeBag())
        } catch let error {
            print("Add new object failed: \(error)")
        }
    }
    
    static func deleteAnObject(id: Int) {
        do {
            let realm = try Realm()
            guard let didLikeImage = realm.object(ofType: self,
                                                  forPrimaryKey: id) else { return }
            try realm.write {
                realm.delete(didLikeImage)
            }
        } catch let error {
            print("Delete object failed: \(error)")
        }
    }
    
    static func getAllResult() -> Observable<Results<DidLikeHit>> {
        return Observable.create{ observer in
            do {
                let realm = try Realm()
                observer.onNext(realm.objects(DidLikeHit.self))
                observer.onCompleted()
            } catch let error {
                print("Get all result form DidLikeHit failed: \(error)")
            }
            return Disposables.create()
        }
    }
    
    static func getAllResultId() -> Observable<[Int]> {
        return Observable.create{ observer in
            do {
                let realm = try Realm()
                var hitsId: [Int] = []
                let hits = Array(realm.objects(DidLikeHit.self))
                for hit in hits {
                    hitsId.append(hit.id)
                }
                observer.onNext(hitsId)
                observer.onCompleted()
            } catch let error {
                print("Get all id form DidLikeHit failed: \(error)")
            }
            return Disposables.create()
        }
    }
    static func convertToDidLikeHit(hit: Hit) -> DidLikeHit {
        let didLikeHit = DidLikeHit()
        didLikeHit.id = hit.id
        didLikeHit.url = hit.imageURL
        didLikeHit.imageWidth = Float(hit.imageWidth)
        didLikeHit.imageHeight = Float(hit.imageHeight)
        didLikeHit.userImageUrl = hit.userImageUrl
        didLikeHit.username = hit.username
        return didLikeHit
    }
}
