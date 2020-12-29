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
    
    private var didLikeHits: [Hit] = []
    var userViewModel: UserViewModel?
    private var didDislikeImagesId: Set<Int> = []
    private var didLikeHitsRelay = BehaviorRelay<[Hit]>(value: [])
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        didLikeHits = userViewModel?.getDidLikeHit(didLikeHits: DidLikeHit.getListDidLikeHit()) ?? []
        hitTableView.register(UINib.init(nibName: "TableViewCell", bundle: nil),
                              forCellReuseIdentifier: "cell")
        scrollToRow()
        
        var value = didLikeHitsRelay.value
        value.append(contentsOf: didLikeHits)
        didLikeHitsRelay.accept(value)
        initUserTableViewCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let newDidLikeHits = userViewModel?.getDidLikeHit(didLikeHits: DidLikeHit.getListDidLikeHit()) ?? []
        let setDidLikeHits = Set(didLikeHits)
        let setNewDidLikeHits = Set(newDidLikeHits)
        if setDidLikeHits != setNewDidLikeHits {
            didLikeHits = newDidLikeHits
            hitTableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        for id in didDislikeImagesId {
            DidLikeHit.deleteAnObject(id: id)
        }
    }
    
    // Create cell
    func initUserTableViewCell() {
        didLikeHitsRelay
            .bind(to: hitTableView.rx.items(cellIdentifier: "cell", cellType: HitTableViewCell.self)) { indexPath,hit,cell in
                cell.hit = hit
                cell.setHeightOfHitImageView(imageWidth: CGFloat(hit.imageWidth),
                                             imageHeight: CGFloat(hit.imageHeight))
                cell.delegate = self
                cell.handleLikeButton(hit: hit, didDislikeImagesId: self.didDislikeImagesId)
                
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
        didDislikeImagesId.remove(id)
    }
    
    func didDisLikeImage(id: Int) {
        didDislikeImagesId.insert(id)
    }
}
