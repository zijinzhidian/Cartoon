//
//  UBaseTableViewCell.swift
//  Cartoon
//
//  Created by apple on 2018/11/6.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

class UBaseTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func configUI() {}
}
