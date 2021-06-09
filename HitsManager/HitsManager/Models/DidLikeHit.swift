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
    @objc dynamic var autherImageUrl = ""
    @objc dynamic var autherName = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    static func addAnObject(hit: Hit) {
        do {
            let realm = try Realm()
            let didLikeImage = hit.asDidLikeHit()
            Observable.from(object: didLikeImage)
                .subscribe(realm.rx.add())
                .disposed(by: DisposeBag())
        } catch let error {
            print("Add new object failed: \(error.localizedDescription)")
        }
    }
    
    static func deleteAnObject(id: Int) {
        do {
            let realm = try Realm()
            guard let didLikeHit = realm.object(ofType: self,
                                                  forPrimaryKey: id) else { return }
            try realm.write {
                realm.delete(didLikeHit)
            }
        } catch let error {
            print("Delete object failed: \(error.localizedDescription)")
        }
    }
    
    static func getAllResult() -> Results<DidLikeHit> {
        let realm = try! Realm()
        return realm.objects(self)
    }
    
    static func asObservable() -> Observable<Results<DidLikeHit>> {
        let realm = try! Realm()
        return Observable.collection(from: realm.objects(self))
    }
    
    func asHit() -> Hit {
        let hit = Hit(id: id, imageUrl: url, imageWidth: CGFloat(imageWidth), imageHeight: CGFloat(imageHeight), userImageUrl: autherImageUrl, username: autherName)
        return hit
    }
}
