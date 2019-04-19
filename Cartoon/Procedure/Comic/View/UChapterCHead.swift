//
//  UChapterCHead.swift
//  Cartoon
//
//  Created by apple on 2018/12/28.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

class UChapterCHead: UBaseCollectionReusableView {
    
    var sortClosure: ((_ button: UIButton) -> Void)?
    
    private lazy var chapterLabel: UILabel = {
        let cl = UILabel()
        cl.textColor = UIColor.gray
        cl.font = UIFont.systemFont(ofSize: 13)
        return cl
    }()
    
    private lazy var sortButton: UIButton = {
        let sn = UIButton(type: .system)
        sn.setTitle("倒序", for: .normal)
        sn.setTitleColor(UIColor.gray, for: .normal)
        sn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        sn.addTarget(self, action: #selector(sortAction(for:)), for: .touchUpInside)
        return sn
    }()
    
    var model: DetailStaticModel? {
        didSet {
            guard let model = model else { return }
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd"
            chapterLabel.text = "目录 \(format.string(from: Date(timeIntervalSince1970: model.comic?.last_update_time ?? 0))) 更新 \(model.chapter_list?.last?.name ?? "")"
        }
    }
    
    @objc private func sortAction(for button: UIButton) {
        guard let sortClosure = sortClosure else { return }
        sortClosure(button)
    }
    
    override func configUI() {
        
        addSubview(sortButton)
        sortButton.snp.makeConstraints {
            $0.right.top.bottom.equalToSuperview()
            $0.width.equalTo(44)
        }
        
        addSubview(chapterLabel)
        chapterLabel.snp.makeConstraints {
            $0.left.equalTo(10)
            $0.top.bottom.equalToSuperview()
            $0.right.equalTo(sortButton.snp.left).offset(-10)
        }
    }
    
}
