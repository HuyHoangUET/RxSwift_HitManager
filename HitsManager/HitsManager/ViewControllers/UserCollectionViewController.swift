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
    private var isSubcribe = true
    
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
        // update data for collectionView
//        if userViewModel.isDatabaseChange {
//            isSubcribe = true
//            self.imageCollectionView.dataSource = nil
//            userViewModel.updateDidLikeHits()
//            userViewModel.isDatabaseChange = false
//        }
        
        let realm = try! Realm()
        let hits = realm.objects(DidLikeHit.self)
        Observable.changeset(from: hits)
            .subscribe(onNext: { changes in
                self.isSubcribe = true
                self.imageCollectionView.dataSource = nil
                self.userViewModel.updateDidLikeHits()
            })
            .disposed(by: bag)
        customNumberOfImageLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        isSubcribe = false
    }
}

// MARK: - cell
extension UserCollectionViewController: UICollectionViewDelegateFlowLayout {
    // Create cell
    func initUserCollectionViewCell() {
        // dataSourse
        dataSource = RxCollectionViewSectionedReloadDataSource<SectionOfHit>(
          configureCell: { dataSource, collectionView, indexPath, item in
            let cell = self.imageCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HitCollectionViewCell
            cell.hit = item
            cell.likeButton.isHidden = true
            cell.configureCell()
            return cell
        })
        // bind to collectionVew
        userViewModel.didLikeHitsRelay
            .takeWhile { hits in
                self.isSubcribe == true
            }
            .subscribe(onNext: { hits in
                let sections = [SectionOfHit(items: hits)]
                Observable.just(sections)
                    .bind(to: self.imageCollectionView.rx.items(dataSource: self.dataSource))
                    .disposed(by: self.bag)
            })
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
