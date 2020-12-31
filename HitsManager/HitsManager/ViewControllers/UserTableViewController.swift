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
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        guard userViewModel != nil else {
            return
        }
        for id in userViewModel!.didDislikeImagesId {
            DidLikeHit.deleteAnObject(id: id)
        }
    }
    
    // Create cell
    func initUserTableViewCell() {
        guard userViewModel != nil else {
            return
        }
        userViewModel!.didLikeHitsRelay
            .bind(to: hitTableView.rx.items(cellIdentifier: "cell", cellType: HitTableViewCell.self)) { indexPath,hit,cell in
                cell.hit = hit
                cell.setHeightOfHitImageView(imageWidth: CGFloat(hit.imageWidth),
                                             imageHeight: CGFloat(hit.imageHeight))
                cell.delegate = self
                cell.handleLikeButton(hit: hit, didDislikeImagesId: self.userViewModel!.didDislikeImagesId)
                
                // user imageview
                cell.setImageForUserView()
                
                // hit imageview
                cell.setImageForHitImageView()
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
