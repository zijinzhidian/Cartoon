//
//  UCommentTCell.swift
//  Cartoon
//
//  Created by apple on 2018/12/28.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

class UCommentTCell: UBaseTableViewCell {
    
    private lazy var iconView: UIImageView = {
        let iw = UIImageView()
        iw.contentMode = .scaleAspectFill
        iw.layer.cornerRadius = 20
        iw.layer.masksToBounds = true
        return iw
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let nl = UILabel()
        nl.textColor = UIColor.gray
        nl.font = UIFont.systemFont(ofSize: 13)
        return nl
    }()
    
    private lazy var contentTextView: UITextView = {
        let cw = UITextView()
        cw.isUserInteractionEnabled = false
        cw.font = UIFont.systemFont(ofSize: 13)
        cw.textColor = UIColor.black
        return cw
    }()
    
    var viewModel: UCommentViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            iconView.kf.setImage(urlString: viewModel.model?.face)
            nickNameLabel.text = viewModel.model?.nickname
            contentTextView.text = viewModel.model?.content_filter
        }
    }
    
    override func configUI() {
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.left.top.equalToSuperview().offset(10)
            $0.width.height.equalTo(40)
        }
        
        contentView.addSubview(nickNameLabel)
        nickNameLabel.snp.makeConstraints {
            $0.left.equalTo(iconView.snp.right).offset(10)
            $0.top.equalTo(iconView)
            $0.right.equalToSuperview().offset(-10)
            $0.height.equalTo(15)
        }
        
        contentView.addSubview(contentTextView)
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(10)
            $0.left.right.equalTo(nickNameLabel)
            $0.bottom.greaterThanOrEqualToSuperview().offset(-10)
        }
    }
}

class  UCommentViewModel {
    
    var model: CommentModel?
    var height: CGFloat = 0
    
    convenience init(model: CommentModel) {
        self.init()
        self.model = model
        
        let tw = UITextView().then { $0.font = UIFont.systemFont(ofSize: 13) }
        tw.text = model.content_filter
        let height = tw.sizeThatFits(CGSize(width: screenWidth - 70, height: CGFloat.infinity)).height
        self.height = max(60, height + 45)
    }
}
