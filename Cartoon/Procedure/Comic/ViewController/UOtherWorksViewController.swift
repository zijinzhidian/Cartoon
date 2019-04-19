//
//  UOtherWorksViewController.swift
//  Cartoon
//
//  Created by apple on 2018/12/25.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

private let kOtherWorkCCellID = "otherWorkCCellID"

class UOtherWorksViewController: UBaseViewController {
    
    var otherWorks: [OtherWorkModel]?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        let cw = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cw.backgroundColor = UIColor.white
        cw.delegate = self
        cw.dataSource = self
        cw.register(UOtherWorksCCell.self, forCellWithReuseIdentifier: kOtherWorkCCellID)
        return cw
    }()
    
    convenience init(otherWorks: [OtherWorkModel]?) {
        self.init()
        self.otherWorks = otherWorks
    }
    
    override func configUI() {
        
        title = "其他作品"
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

extension UOtherWorksViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return otherWorks?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kOtherWorkCCellID, for: indexPath) as! UOtherWorksCCell
        cell.model = otherWorks?[indexPath.row]
        return cell
    }
}

extension UOtherWorksViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((collectionView.frame.width - 40) / 3)
        return CGSize(width: width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = otherWorks?[indexPath.row] else { return }
        let vc = UComicViewController(comicid: model.comicId)
        navigationController?.pushViewController(vc, animated: true)
    }
}
