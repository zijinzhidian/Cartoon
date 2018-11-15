//
//  UTabBarController.swift
//  有妖气漫画
//
//  Created by apple on 2018/10/31.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

class UTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.isTranslucent = false
        
        
        //首页
        let onePageVC = UHomeViewController(titles: ["推荐", "VIP", "订阅", "排行"],
                                            vcs: [UBoutiqueListViewController(),
                                                  UVIPListViewController(),
                                                  USubscibeListViewController(),
                                                  URankListViewController()],
                                            pageStyle: .navigationBarSegment)
        addChildViewController(onePageVC, title: "首页", image: UIImage(named: "tab_home"), selectedImage: UIImage(named: "tab_home_S"))
        
        //分类
        let classVC = UBaseViewController()
        addChildViewController(classVC, title: "分类", image: UIImage(named: "tab_class"), selectedImage: UIImage(named: "tab_class_S"))
        
        //书架
        let bookVC = UBaseViewController()
        addChildViewController(bookVC, title: "书架", image: UIImage(named: "tab_book"), selectedImage: UIImage(named: "tab_book_S"))
        
        //我的
        let mineVC = UBaseViewController()
        addChildViewController(mineVC, title: "我的", image: UIImage(named: "tab_mine"), selectedImage: UIImage(named: "tab_mine_S"))
    }
    
    fileprivate func addChildViewController(_ childController: UIViewController, title: String?, image: UIImage?, selectedImage: UIImage?) {
        //导航栏标题
        childController.title = title
        //tabBarItem上的图片选中时默认时蓝色的,所以需要使用alwaysOriginal显示原始图片
        childController.tabBarItem = UITabBarItem(title: nil, image: image?.withRenderingMode(.alwaysOriginal), selectedImage: selectedImage?.withRenderingMode(.alwaysOriginal))
        //设置图片偏移量
        if UIDevice.current.userInterfaceIdiom == .phone {
            childController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        addChild(UNavigationController(rootViewController: childController))
    }
}


//extension UTabBarController {
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        guard let select = selectedViewController else { return .lightContent }
//        return select.preferredStatusBarStyle
//    }
//}
