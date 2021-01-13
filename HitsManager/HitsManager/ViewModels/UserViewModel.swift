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
    var didDislikeHitsId: Set<Int> = []
}
