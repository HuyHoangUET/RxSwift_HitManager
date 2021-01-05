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

class UserTableViewController: UIViewController {
    
    // MARK: - outlet
    @IBOutlet weak var hitTableView: UITableView!
    
    var userViewModel: UserViewModel?
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard userViewModel != nil else {
            return
        }
        hitTableView.register(UINib.init(nibName: "TableViewCell", bundle: nil),
                              forCellReuseIdentifier: "cell")
        scrollToRow()
        
        initUserTableViewCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        guard userViewModel != nil else {
            return
        }
        if userViewModel!.isDatabaseChange {
            let userCollectionView = UserCollectionViewController()
            if userCollectionView.imageCollectionView != nil {
                userCollectionView.imageCollectionView.dataSource = nil
            }
            userViewModel!.updateDidLikeHits()
            userViewModel!.isDatabaseChange = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        guard userViewModel != nil else {
            return
        }
        for id in userViewModel!.didDislikeImagesId {
            DidLikeHit.deleteAnObject(id: id)
        }
        hitTableView.dataSource = nil
    }
    
    // Create cell
    func initUserTableViewCell() {
        guard userViewModel != nil else {
            return
        }
        // dataSourse
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfHit>(
          configureCell: { dataSource, tableView, indexPath, item in
            let cell = self.hitTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HitTableViewCell
            cell.hit = item
            cell.setHeightOfHitImageView(imageWidth: CGFloat(item.imageWidth),
                                                         imageHeight: CGFloat(item.imageHeight))
            cell.handleLikeButton(hit: item, didDislikeImagesId: self.userViewModel!.didDislikeImagesId)
            cell.configureCell()
            return cell
        })
        userViewModel!.didLikeHitsRelay.subscribe(onNext: { hits in
            let sections = [SectionOfHit(items: hits)]
            Observable.just(sections)
                .bind(to: self.hitTableView.rx.items(dataSource: dataSource))
                .disposed(by: self.bag)
        })
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
                self.userViewModel?.chosenIndexPath.subscribe(onNext: { indexPath in
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
    }
}
