//
//  ViewController.swift
//  HitsManager
//abc
//  Created by LTT on 11/2/20.
//

import UIKit
import Nuke
import RxSwift
import RxCocoa
import RxDataSources

class HitCollectionViewController: UIViewController, UICollectionViewDelegate {
    // MARK: - outlet
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainView: UIView!
    
    private let viewModel = ViewModel()
    private let userView = UserCollectionViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.register(UINib.init(nibName: "CollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "cell")
        viewModel.getHitsByPage()
        initHitCollectionViewCell()
        handleSellectedCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        collectionView.reloadData()
    }
    
    // Create cell
    func initHitCollectionViewCell() {
        viewModel.hitsRelay
            .bind(to: collectionView.rx.items(cellIdentifier: "cell",
                                              cellType: HitCollectionViewCell.self)) { indexPath,hit,cell in
                cell.delegate = self
                let hitId = hit.id
                cell.handleLikeButton(hitId: hitId)
                cell.hit = hit
                cell.configureCell()
            }
            .disposed(by: bag)
    }
    // sellected cell
    func handleSellectedCell() {
        collectionView.rx.itemSelected
            .bind { indexPath in
                if self.viewModel.sellectedCell != indexPath {
                    self.viewModel.sellectedCell = indexPath
                } else {
                    self.viewModel.sellectedCell = IndexPath()
                }
                self.collectionView.performBatchUpdates(nil, completion: nil)
            }
            .disposed(by: bag)
    }
}

// Custom cell
extension HitCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return SizeOfCollectionViewItem.getInsetOfSection()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if viewModel.sellectedCell == indexPath {
            let cell = collectionView.cellForItem(at: indexPath) as! HitCollectionViewCell
            return SizeOfCollectionViewItem.getSizeForDidSellectItem(imageWidth: cell.hit.imageWidth,
                                                                     imageHeight: cell.hit.imageHeight)
        }
        
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

// Load next page
extension HitCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView,
                        prefetchItemsAt indexPaths: [IndexPath]) {
        viewModel.getHitsInNextPage(indexPaths: indexPaths)
    }
}

// Handle like image
extension HitCollectionViewController: HitCollectionViewDelegate {
    
    func didLikeImage(hit: Hit) {
        let setDidLikeHitId = Set(DidLikeHit.getListId())
        if !setDidLikeHitId.isSuperset(of: [hit.id]) {
            DidLikeHit.addAnObject(hit: hit)
        }
    }
    
    func didDisLikeImage(id: Int) {
        DidLikeHit.deleteAnObject(id: id)
    }
}

// Safe array
extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        return self[index]
    }
}
