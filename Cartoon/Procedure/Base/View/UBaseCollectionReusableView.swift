//
//  UBaseCollectionReusableView.swift
//  Cartoon
//
//  Created by apple on 2018/11/3.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

class UBaseCollectionReusableView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func configUI() {}
}
