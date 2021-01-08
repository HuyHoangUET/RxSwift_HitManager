//
//  UserTableViewController.swift
//  HitsManager
//
//  Created by LTT on 20/11/2020.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxRealm
import RealmSwift

class UserTableViewController: UIViewController {
    
    // MARK: - outlet
    @IBOutlet weak var hitTableView: UITableView!
    
    var userViewModel: UserViewModel?
    private let bag = DisposeBag()
    private var isSubcribe = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard userViewModel != nil else {
            return
        }
        hitTableView.register(UINib.init(nibName: "TableViewCell", bundle: nil),
                              forCellReuseIdentifier: "cell")
        // show sellected image
        scrollToRow()
        // init cell
        initUserTableViewCell()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        guard userViewModel != nil else {
            return
        }
        // delete disLiked image
        for id in userViewModel!.didDislikeImagesId {
            DidLikeHit.deleteAnObject(id: id)
        }
        isSubcribe = false
    }
    
    // Create cell
    func initUserTableViewCell() {
        guard userViewModel != nil else {
            return
        }
        
        let realm = try! Realm()
        let hits = realm.objects(DidLikeHit.self)
        Observable.collection(from: hits )
            .bind(to: hitTableView.rx.items(cellIdentifier: "cell", cellType: HitTableViewCell.self)) {indexPath, didLikeHit, cell in
                let hit = Hit(id: didLikeHit.id, imageUrl: didLikeHit.url, imageWidth: CGFloat(didLikeHit.imageWidth), imageHeight: CGFloat(didLikeHit.imageHeight), userImageUrl: didLikeHit.userImageUrl, username: didLikeHit.username)
                cell.hit = hit
                cell.setHeightOfHitImageView(imageWidth: CGFloat(didLikeHit.imageWidth),
                                                           imageHeight: CGFloat(hit.imageHeight))
                cell.handleLikeButton(hit: hit, didDislikeImagesId: self.userViewModel!.didDislikeImagesId)
                cell.delegate = self
                cell.configureCell()
            }
            .disposed(by: bag)
    }
}

extension UserTableViewController {
    func scrollToRow(){
        DispatchQueue.main.async {
            guard self.userViewModel != nil else {
                return
            }
            if self.userViewModel!.isDisplayCellAtChosenIndexPath {
                self.userViewModel?.chosenIndexPath
                    .subscribe(onNext: { indexPath in
                        self.hitTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                    })
                    .disposed(by: DisposeBag())
            }
        }
    }
}

extension UserTableViewController: UserTableViewCellDelegate {
    func didLikeImage(id: Int) {
        userViewModel?.didDislikeImagesId.remove(id)
    }
    
    func didDisLikeImage(id: Int) {
        userViewModel?.didDislikeImagesId.insert(id)
        DidLikeHit.deleteAnObject(id: id)
    }
}
