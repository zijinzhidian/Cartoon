//
//  UChapterViewController.swift
//  Cartoon
//
//  Created by apple on 2018/12/25.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

private let kChapterCHeadID = "chapterCHeadID"
private let kChapterCCellID = "chapterCCellID"

class UChapterViewController: UBaseViewController {
    
    var detailStatic: DetailStaticModel?
    var detailRealtime: DetailRealtimeModel?
    
    weak var delegate: UComicViewWillEndDraggingDelegate?
    
    private var isPositive: Bool = true
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: floor((screenWidth - 30) / 2), height: 40)
        let cw = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cw.backgroundColor = UIColor.white
        cw.alwaysBounceVertical = true
        cw.delegate = self
        cw.dataSource = self
        cw.register(UChapterCCell.self, forCellWithReuseIdentifier: kChapterCCellID)
        cw.register(UChapterCHead.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: kChapterCHeadID)
        return cw
    }()
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    override func configUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

extension UChapterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return detailStatic?.chapter_list?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kChapterCCellID, for: indexPath) as! UChapterCCell
        if isPositive {
            cell.chapterStatic = detailStatic?.chapter_list?[indexPath.row]
        } else {
            cell.chapterStatic = detailStatic?.chapter_list?.reversed()[indexPath.row]
        }
        return cell
    }
}

extension UChapterViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let head = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: kChapterCHeadID, for: indexPath) as! UChapterCHead
        head.model = detailStatic
        head.sortClosure = { [weak self] button in
            if self?.isPositive == true {
                self?.isPositive = false
                button.setTitle("正序", for: .normal)
            } else {
                self?.isPositive = true
                button.setTitle("倒序", for: .normal)
            }
            self?.collectionView.reloadData()
        }
        return head
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: 44)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.comicWillEndDragging(scrollView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = isPositive ? indexPath.row : ((detailStatic?.chapter_list?.count)! - indexPath.row - 1)
        let vc = UReadViewController(detailStatic: detailStatic, selectIndex: index)
        navigationController?.pushViewController(vc, animated: true)
    }
}
