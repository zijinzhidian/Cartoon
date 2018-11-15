//
//  UBaseTableViewHeaderFooterView.swift
//  Cartoon
//
//  Created by apple on 2018/11/10.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

class UBaseTableViewHeaderFooterView: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func configUI() {}
    
}
