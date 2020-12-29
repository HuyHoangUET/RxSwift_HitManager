//
//  HitAPI.swift
//  HitsManager
//
//  Created by LTT on 11/2/20.
//

import Foundation
import Alamofire
import AlamofireImage
import SQLite3
import RxSwift
import RxCocoa

let apiURL = "https://pixabay.com/api/?key=13112092-54e8286568142add194090167&q=girl"

class HitAPI {
    // Singleton
    static var shared = HitAPI()
    
    func get(url: String) -> Observable<Data> {
        return Observable.create { observer in
            guard url != "" else { return Disposables.create() }
            AF.request(url).response {
                response in
                if response.data != nil {
                    let data = response.data
                    observer.onNext(data!)
                    observer.onCompleted()
                } else {
                    print(response.error as Any)
                }
            }
            return Disposables.create()
        }
    }
}
