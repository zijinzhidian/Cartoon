//
//  UOtherWorksTCell.swift
//  Cartoon
//
//  Created by apple on 2018/12/25.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

class UOtherWorksTCell: UBaseTableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var model: DetailStaticModel? {
        didSet {
            guard let model = model else { return }
            textLabel?.text = "其他作品"
            detailTextLabel?.text = "\(model.otherWorks?.count ?? 0)本"
            detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
        }
    }
    
}
