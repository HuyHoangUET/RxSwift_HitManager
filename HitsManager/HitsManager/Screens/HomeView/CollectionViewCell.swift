//
//  CollectionViewCell.swift
//  HitsManager
//
//  Created by LTT on 11/2/20.
//

import Foundation
import UIKit
import Nuke
import RxSwift

class HitCollectionViewCell: UICollectionViewCell {
    // MARK: - outlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    var hit = Hit()
    private let bag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        likeButton.setImage(nil, for: .normal)
    }
    
    func configureCell() {
        guard hit.imageURL != "" else { return }
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "placeholder")
            )
        Nuke.loadImage(with: URL(string: hit.imageURL)!,
                       options: options, into: imageView)
    }
    
    func handleLikeButton(hit: Hit) {
        DidLikeHit.asObservable().subscribe(onNext: { result in
            if Set(result.value(forKey: "id") as! [Int]).isSuperset(of: [hit.imageId]) {
                self.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            } else {
                self.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
        })
        .disposed(by: bag)
    }
    
    // MARK: - action
    @IBAction func likeButton(_ sender: UIButton) {
        let heartImage = UIImage(systemName: "heart.fill")
        if sender.currentImage == heartImage {
            DidLikeHit.deleteAnObject(id: hit.imageId)
        } else {
            let result = DidLikeHit.getAllResult()
            if !Set(result.value(forKey: "id") as! [Int]).isSuperset(of: [hit.imageId]) {
                DidLikeHit.addAnObject(hit: hit)
            }
        }
    }
}
