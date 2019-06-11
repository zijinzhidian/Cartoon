//
//  UReadViewController.swift
//  Cartoon
//
//  Created by apple on 2018/12/29.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

class UReadViewController: UBaseViewController {
    
    private var chapterList = [ChapterModel]()
    
    private var detailStatic: DetailStaticModel?
    
    private var selectIndex: Int = 0
    
    private var previousIndex: Int = 0
    
    private var nextIndex: Int = 0
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let cw = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cw.backgroundColor = UIColor.background
        cw.delegate = self
//        cw.dataSource = self
        return cw
    }()
    
    
}

//extension UReadViewController: UICollectionViewDataSource {
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return chapterList.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return chapterList[section].image_list?.count ?? 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return nil;
//    }
//}

extension UReadViewController: UICollectionViewDelegate {
    
}
