//
//  UChapterCCell.swift
//  Cartoon
//
//  Created by feibi on 2020/4/27.
//  Copyright © 2020 hzbojin. All rights reserved.
//

import UIKit

class UChapterCCell: UBaseCollectionViewCell {
    lazy var nameLabel: UILabel = {
        let nl = UILabel()
        nl.font = UIFont.systemFont(ofSize: 16)
        return nl
    }()
    
    override func configUI() {
        contentView.backgroundColor = UIColor.white
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        layer.masksToBounds = true
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)) }
    }
    
    var chapterStatic: ChapterStaticModel? {
        didSet {
            guard let chapterStatic = chapterStatic else { return }
            nameLabel.text = chapterStatic.name
        }
    }
}
