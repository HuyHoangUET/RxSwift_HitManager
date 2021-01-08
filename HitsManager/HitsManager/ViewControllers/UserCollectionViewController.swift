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
import RxDataSources
import RxRealm
import RealmSwift

class UserCollectionViewController: UIViewController{
    
    // MARK: - outlet
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var numberOfImagesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    private let userViewModel = UserViewModel()
    private let bag = DisposeBag()
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionOfHit>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.delegate = self
        imageCollectionView.register(UINib.init(nibName: "CollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: "cell")
        // display user
        customUserImage()
        customUsernameLabel()
        // display tableviewcell
        userViewModel.updateDidLikeHits()
        initUserCollectionViewCell()
        handleSellectCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        customNumberOfImageLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
    }
}

// MARK: - cell
extension UserCollectionViewController: UICollectionViewDelegateFlowLayout {
    // Create cell
    func initUserCollectionViewCell() {
        let realm = try! Realm()
        let hits = realm.objects(DidLikeHit.self)
        Observable.collection(from: hits )
            .bind(to: imageCollectionView.rx.items(cellIdentifier: "cell", cellType: HitCollectionViewCell.self)) {indexPath, didLikeHit, cell in
                let hit = Hit(id: didLikeHit.id, imageUrl: didLikeHit.url, imageWidth: CGFloat(didLikeHit.imageWidth), imageHeight: CGFloat(didLikeHit.imageHeight), userImageUrl: didLikeHit.userImageUrl, username: didLikeHit.username)
                cell.hit = hit
                cell.likeButton.isHidden = true
                cell.configureCell()
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
    // Custom cell
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

// MARK: - userView
extension UserCollectionViewController {
    func customUserImage() {
        userImageView.layer.cornerRadius = userImageView.frame.width / 2.0
        userImageView.layer.masksToBounds = true
    }
    
    func customUsernameLabel() {
        usernameLabel.text = "username"
    }
    
    func customNumberOfImageLabel() {
        numberOfImagesLabel.text = "\(userViewModel.didLikeHitsRelay.value.count) ảnh đã thích"
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
