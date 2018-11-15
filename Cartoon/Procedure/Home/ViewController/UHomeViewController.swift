//
//  UHomeViewController.swift
//  有妖气漫画
//
//  Created by apple on 2018/10/31.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

class UHomeViewController: UPageViewController {
    override func configNavigationBar() {
        super.configNavigationBar()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav_search")?.withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.plain, target: self, action: #selector(searchAction))
    }
    
    @objc private func searchAction() {
        navigationController?.pushViewController(USearchViewController(), animated: true)
    }
}
