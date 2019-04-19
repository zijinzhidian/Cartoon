//
//  UGuessLikeTCell.swift
//  Cartoon
//
//  Created by apple on 2018/12/25.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

private let kComicCCellID = "kComicCCellID"

class UGuessLikeTCell: UBaseTableViewCell {
    
    var didSelectClosure: ((_ comic: ComicModel) -> Void)?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        let cw = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cw.backgroundColor = self.contentView.backgroundColor
        cw.delegate = self
        cw.dataSource = self
        cw.isScrollEnabled = false
        cw.register(UComicCCell.self, forCellWithReuseIdentifier: kComicCCellID)
        return cw
    }()
    
    
    var model: GuessLikeModel? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    override func configUI() {
        let titleLabel = UILabel().then {
            $0.text = "猜你喜欢"
        }
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.left.right.equalToSuperview().inset(UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
            $0.height.equalTo(20)
        }
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.left.bottom.right.equalToSuperview()
        }
    }
}

extension UGuessLikeTCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((collectionView.frame.width - 50) / 4)
        let height = collectionView.frame.height - 10
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let comic = model?.comics?[indexPath.row],
            let didSelectClosure = didSelectClosure else { return }
        didSelectClosure(comic)
    }
}

extension UGuessLikeTCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.comics?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kComicCCellID, for: indexPath) as! UComicCCell
        cell.style = .withTitle
        cell.model = model?.comics?[indexPath.row]
        return cell
    }
}
