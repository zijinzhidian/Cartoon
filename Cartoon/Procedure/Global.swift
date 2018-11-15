//
//  Global.swift
//  Cartoon
//
//  Created by apple on 2018/11/1.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

extension UIColor {
    class var background: UIColor {
        return UIColor(r: 242, g: 242, b: 242)
    }
    
    class var theme: UIColor {
        return UIColor(r: 29, g: 221, b: 43)
    }
}

extension String {
    static let sexTypeKey = "sexTypeKey"
    static let searchHistoryKey = "searchHistoryKey"
}

extension NSNotification.Name {
    static let USexTypeDidChange = NSNotification.Name("USexTypeDidChange")
}

var topVC: UIViewController? {
    var resultVC: UIViewController?
    resultVC = _topVC(UIApplication.shared.keyWindow?.rootViewController)
    while resultVC?.presentedViewController != nil {
        resultVC = _topVC(resultVC?.presentedViewController)
    }
    return resultVC
}

private func _topVC(_ vc: UIViewController?) -> UIViewController? {
    if vc is UINavigationController {
        return _topVC((vc as? UINavigationController)?.topViewController)
    } else if vc is UITabBarController {
        return _topVC((vc as? UITabBarController)?.selectedViewController)
    } else {
        return vc
    }
}

//MARK: Kingfisher
extension Kingfisher where Base: ImageView {     //Base为泛型,where Base: ImageView表示Base必须是ImageView类型
    @discardableResult
    public func setImage(urlString: String?, placeholder: Placeholder? = UIImage(named: "normal_placeholder_h")) -> RetrieveImageTask {
        return setImage(with: URL(string: urlString ?? ""), placeholder: placeholder, options: [.transition(.fade(3))], progressBlock: nil, completionHandler: nil)
        
    }
}

//MARK: SnapKit
extension ConstraintView {
    var usnp: ConstraintBasicAttributesDSL {
        if #available(iOS 11.0, *) {
            //safeAreaLayoutGuide代表UIView的安全区域,可以作为参照物,让其相对于该UIView的safeAreaLayoutGuide做布局
            return self.safeAreaLayoutGuide.snp
        } else {
            return self.snp
        }
    }
}
