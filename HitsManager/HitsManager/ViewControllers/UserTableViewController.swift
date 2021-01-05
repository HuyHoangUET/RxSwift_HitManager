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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        guard userViewModel != nil else {
            return
        }
        // update data
        if userViewModel!.isDatabaseChange {
            isSubcribe = true
            hitTableView.dataSource = nil
            userViewModel!.updateDidLikeHits()
        }
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
        // dataSourse
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfHit>(
          configureCell: { dataSource, tableView, indexPath, item in
            let cell = self.hitTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HitTableViewCell
            cell.hit = item
            cell.setHeightOfHitImageView(imageWidth: CGFloat(item.imageWidth),
                                                         imageHeight: CGFloat(item.imageHeight))
            cell.handleLikeButton(hit: item, didDislikeImagesId: self.userViewModel!.didDislikeImagesId)
            cell.delegate = self
            cell.configureCell()
            return cell
        })
        // bind to tableView
        userViewModel!.didLikeHitsRelay
            .takeWhile { hits in
                self.isSubcribe == true
            }
            .subscribe(onNext: { hits in
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
