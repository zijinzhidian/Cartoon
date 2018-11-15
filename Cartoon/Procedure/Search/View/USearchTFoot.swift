//
//  USearchTFoot.swift
//  Cartoon
//
//  Created by apple on 2018/11/10.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

class USearchCCell: UBaseCollectionViewCell {
    lazy var titleLabel: UILabel = {
        let tl = UILabel()
        tl.textAlignment = .center
        tl.font = UIFont.systemFont(ofSize: 14)
        tl.textColor = UIColor.darkGray
        return tl
    }()
    
    override func configUI() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.background.cgColor
        layer.cornerRadius = layer.bounds.height * 0.5
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        }
    }
}

typealias USearchTFootDidSelectIndexClosure = (_ index: Int, _ model: SearchItemModel) -> Void

private let kSearchCCellID = "searchCCellID"

class USearchTFoot: UBaseTableViewHeaderFooterView {
    
    var didSelecteIndexClosure: USearchTFootDidSelectIndexClosure?
    
    private lazy var collectionView: UICollectionView = {
        let lt = UCollectionViewAlignedLayout()
        lt.horizontalAlignment = .left
        lt.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        lt.minimumLineSpacing = 10
        lt.minimumInteritemSpacing = 10
        lt.estimatedItemSize = CGSize(width: 100, height: 40)
        
        let cw = UICollectionView(frame: CGRect.zero, collectionViewLayout: lt)
        cw.backgroundColor = UIColor.white
        cw.dataSource = self
        cw.delegate = self
        cw.register(USearchCCell.self, forCellWithReuseIdentifier: kSearchCCellID)
        return cw
    }()
    
    var data: [SearchItemModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func configUI() {
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension USearchTFoot: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kSearchCCellID, for: indexPath) as! USearchCCell
        cell.titleLabel.text = data[indexPath.row].name
        return cell
    }
}


extension USearchTFoot: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let closure = didSelecteIndexClosure else { return }
        closure(indexPath.row, data[indexPath.row])
    }
}
