//
//  UReadCCell.swift
//  Cartoon
//
//  Created by apple on 2018/12/29.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView: Placeholder {}

class UReadCCell: UBaseCollectionViewCell {
    private lazy var imageView: UIImageView = {
        let iw = UIImageView()
        iw.contentMode = .scaleAspectFill
        return iw
    }()
    
    private lazy var placeholder: UIImageView = {
        let pr = UIImageView(image: UIImage(named: "yaofan"))
        pr.contentMode = .center
        return pr
    }()
    
    override func configUI() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    var model: ImageModel? {
        didSet {
            guard let model = model else { return }
            imageView.kf.setImage(urlString: model.location, placeholder: placeholder)
        }
    }
}
