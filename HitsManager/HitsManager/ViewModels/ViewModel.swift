//
//  ViewModel.swift
//  HitsManager
//
//  Created by LTT on 11/6/20.
//

import Foundation
import UIKit
import RealmSwift
import RxSwift
import RxCocoa

class ViewModel {
    weak var delegate: HitCollectionViewDelegate?
    var sellectedCell = IndexPath()
    private var curentPage = 1
    private let bag = DisposeBag()
    var hitsRelay = BehaviorRelay<[Hit]>(value: [])
    
    // Handle data from api
    func getHitsByPage() -> Observable<Bool> {
        return Observable.create { observer in
            let url = apiURL + "&page=\(String(describing: self.curentPage))"
            HitAPI.shared.get(url: url).subscribe(onNext: {[weak self] data in
                do {
                    let result = try JSONDecoder().decode(Result.self, from: data)
                    observer.onNext(true)
                    observer.onCompleted()
                    var value = self?.hitsRelay.value
                    value?.append(contentsOf: result.hits)
                    self?.hitsRelay.accept(value!)
                } catch let error {
                    print("get hits failed: \(error.localizedDescription)")
                }
            })
            .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    func getHitsInNextPage(indexPaths: [IndexPath]) -> Observable<Bool> {
        return Observable.create { observer in
            if indexPaths.last?.row == self.hitsRelay.value.count - 1 {
                self.curentPage += 1
                self.getHitsByPage().subscribe(onNext: { done in
                    observer.onNext(true)
                    observer.onCompleted()
                })
                .disposed(by: self.bag)
            }
            return Disposables.create()
        }
    }
}
