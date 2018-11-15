//
//  UComicCHead.swift
//  Cartoon
//
//  Created by apple on 2018/11/3.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

typealias UComicCHeadMoreActionClosure = () -> Void

class UComicCHead: UBaseCollectionReusableView {
    
    var moreActionClosure: UComicCHeadMoreActionClosure?
    
    lazy var iconView: UIImageView = {
       return UIImageView()
    }()
    
    lazy var titleLabel: UILabel = {
        let tl = UILabel()
        tl.font = UIFont.systemFont(ofSize: 14)
        tl.textColor = UIColor.black
        return tl
    }()
    
    lazy var moreButton: UIButton = {
        let mn = UIButton(type: .system)
        mn.setTitle("•••", for: .normal)
        mn.setTitleColor(UIColor.lightGray, for: .normal)
        mn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        mn.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
        return mn
    }()
    
    override func configUI() {
        addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(5)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(iconView.snp.right).offset(5)
            $0.centerY.height.equalTo(iconView)
            $0.width.equalTo(200)
        }
        
        addSubview(moreButton)
        moreButton.snp.makeConstraints {
            $0.right.top.bottom.equalToSuperview()
            $0.width.equalTo(40)
        }
    }
    
    @objc func moreAction(button: UIButton) {
        guard let closure = moreActionClosure else { return }
        closure()
    }
}
