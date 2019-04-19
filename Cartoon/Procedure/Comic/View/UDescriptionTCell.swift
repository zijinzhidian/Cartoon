//
//  UDescriptionTCell.swift
//  Cartoon
//
//  Created by apple on 2018/12/25.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

class UDescriptionTCell: UBaseTableViewCell {
    
    lazy var textView: UITextView = {
        let tv = UITextView()
        tv.isUserInteractionEnabled = false
        tv.textColor = UIColor.gray
        tv.font = UIFont.systemFont(ofSize: 15)
        return tv
    }()
    
    override func configUI() {
        let titleLabel = UILabel().then {
            $0.text = "作品介绍"
        }
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.left.right.equalToSuperview().inset(UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
            $0.height.equalTo(20)
        }
        
        contentView.addSubview(textView)
        textView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.left.right.bottom.equalToSuperview().inset(UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        }
    }
    
    var model: DetailStaticModel? {
        didSet {
            guard let model = model else { return }
            textView.text = "【\(model.comic?.cate_id ?? "")】\(model.comic?.description ?? "")"
        }
    }
    
    class func height(for detailStatic: DetailStaticModel?) -> CGFloat {
        var height: CGFloat = 50.0
        guard let model = detailStatic else { return height }
        let textView = UITextView().then { $0.font = UIFont.systemFont(ofSize: 15) }
        textView.text = "【\(model.comic?.cate_id ?? "")】\(model.comic?.description ?? "")"
        height += textView.sizeThatFits(CGSize(width: screenWidth - 30, height: CGFloat.infinity)).height
        return height
    }
}
