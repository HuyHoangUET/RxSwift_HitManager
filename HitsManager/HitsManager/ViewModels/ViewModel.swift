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
    private var curentPage = 0
    var curentPageRelay = BehaviorRelay<Int>(value: 1)
    var hitsRelay = BehaviorRelay<[Hit]>(value: [])
    
    func getHitsByPage() {
        let url = apiURL + "&page=\(String(describing: self.curentPage))"
        HitAPI.shared.get(url: url).subscribe(onNext: {[weak self] data in
            do {
                let result = try JSONDecoder().decode(Result.self, from: data)
                var value = self?.hitsRelay.value
                value?.append(contentsOf: result.hits)
                self?.hitsRelay.accept(value!)
            } catch let error {
                print("get hits failed: \(error.localizedDescription)")
            }
        })
        .disposed(by: bag)
    }
    
    func getHitsInNextPage() {
        curentPageRelay
            .subscribe(onNext: { page in
                self.curentPage += 1
                self.getHitsByPage()
            })
            .disposed(by: bag)
    }
}
