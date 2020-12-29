//
//  UserViewController.swift
//  HitsManager
//
//  Created by LTT on 18/11/2020.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class UserCollectionViewController: UIViewController{
    
    // MARK: - outlet
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var numberOfImagesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    private let userViewModel = UserViewModel()
    private var didLikeHits: [Hit] = []
    private var didLikeHitsRelay = BehaviorRelay<[Hit]>(value: [])
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.delegate = self
        didLikeHits = userViewModel.getDidLikeHit(didLikeHits: DidLikeHit.getListDidLikeHit())
        imageCollectionView.register(UINib.init(nibName: "CollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: "cell")
        customUserImage()
        customUsernameLabel()
        
        var value = didLikeHitsRelay.value
        value.append(contentsOf: didLikeHits)
        didLikeHitsRelay.accept(value)
        initUserCollectionViewCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let newDidLikeHits = userViewModel.getDidLikeHit(didLikeHits: DidLikeHit.getListDidLikeHit())
        let setDidLikeHits = Set(didLikeHits)
        let setNewDidLikeHits = Set(newDidLikeHits)
        
        if setDidLikeHits != setNewDidLikeHits {
            didLikeHits = newDidLikeHits
            imageCollectionView.reloadData()
        }
        customNumberOfImageLabel()
    }
    
    // Create cell
    func initUserCollectionViewCell() {
        
        didLikeHitsRelay
            .bind(to: imageCollectionView.rx.items(cellIdentifier: "cell", cellType: HitCollectionViewCell.self)) { indexPath,hit,cell in
                cell.likeButton.isHidden = true
                cell.hit = hit
                cell.setImage()
            }
            .disposed(by: bag)
    }
    
    // Handle did sellect cell
    func handleSellectCell() {
        imageCollectionView.rx.itemSelected
            .bind { indexPath in
                self.userViewModel.chosenIndexPathSubject.onNext(indexPath)
                self.performSegue(withIdentifier: "segue", sender: nil)
            }
            .disposed(by: bag)
    }
}

// Custom cell
extension UserCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return SizeOfCollectionViewItem.getInsetOfSection()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return SizeOfCollectionViewItem.getSizeForItem()

    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return SizeOfCollectionViewItem.getMinimumInteritemSpacingForSection()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return SizeOfCollectionViewItem.getMinimumLineSpacingForSection()
    }
}

// Display collectionView cell
extension UserCollectionViewController {
    func initHitCollectionViewCell(indexPath: IndexPath) -> HitCollectionViewCell {
        guard let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                                      for: indexPath) as? HitCollectionViewCell else {
            return HitCollectionViewCell()
        }
        cell.hit = didLikeHits[indexPath.row]
        cell.likeButton.isHidden = true
        cell.setImage()
        return cell
    }
}

// Custom user view
extension UserCollectionViewController {
    func customUserImage() {
        userImageView.layer.cornerRadius = userImageView.frame.width / 2.0
        userImageView.layer.masksToBounds = true
    }
    
    func customUsernameLabel() {
        usernameLabel.text = "username"
    }
    
    func customNumberOfImageLabel() {
        numberOfImagesLabel.text = "\(didLikeHits.count) ảnh đã thích"
    }
}

extension UserCollectionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is UserTableViewController {
            let tableView = segue.destination as? UserTableViewController
            userViewModel.isDisplayCellAtChosenIndexPath = true
            tableView?.userViewModel = userViewModel
        }
    }
}
