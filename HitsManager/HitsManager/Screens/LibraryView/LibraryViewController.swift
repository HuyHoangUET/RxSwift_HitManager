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

class LibraryViewController: UIViewController {
    
    // MARK: - outlet
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var numberOfImagesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    private let userViewModel = LibraryViewModel()
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.delegate = self
        imageCollectionView.register(UINib.init(nibName: "CollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: "cell")
        // display user
        customUserImage()
        customUsernameLabel()
        // display tableviewcell
        initUserCollectionViewCell()
        handleSellectCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        customNumberOfImageLabel()
    }
}

// MARK: - cell
extension LibraryViewController: UICollectionViewDelegateFlowLayout {
    // Create cell
    func initUserCollectionViewCell() {
    DidLikeHit.asObservable()
        .bind(to: self.imageCollectionView.rx.items(cellIdentifier: "cell",
                                               cellType: HitCollectionViewCell.self))
        { indexPath, didLikeHit, cell in
            let hit = didLikeHit.asHit()
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
extension LibraryViewController {
    func customUserImage() {
        userImageView.layer.cornerRadius = userImageView.frame.width / 2.0
        userImageView.layer.masksToBounds = true
    }
    
    func customUsernameLabel() {
        usernameLabel.text = "username"
    }
    
    func customNumberOfImageLabel() {
        DidLikeHit.asObservable().subscribe( onNext: { result in
            self.numberOfImagesLabel.text = "\(result.count) ảnh đã thích"
        })
        .disposed(by: bag)
    }
}

extension LibraryViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is StoryViewController {
            let tableView = segue.destination as? StoryViewController
            userViewModel.isDisplayCellAtChosenIndexPath = true
            tableView?.userViewModel = userViewModel
        }
    }
}
