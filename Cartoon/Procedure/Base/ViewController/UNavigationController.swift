//
//  UNavigationController.swift
//  有妖气漫画
//
//  Created by apple on 2018/10/31.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit


class UNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //侧滑手势识别器
        guard let interactionGes = interactivePopGestureRecognizer else { return }
        //侧滑手势所在的view
        guard let targetView = interactionGes.view else { return }
        //侧滑手势的target
        guard let interactionTargets = interactionGes.value(forKeyPath: "targets") as? [NSObject] else { return }
        guard let interactionTarget = interactionTargets.first?.value(forKey: "target") else { return }
        //侧滑手势的action
        let action = Selector(("handleNavigationTransition:"))

        //关闭系统的侧滑返回
        interactionGes.isEnabled = false

        //创建一个全屏滑动的手势
        let fullScreenGes = UIPanGestureRecognizer(target: interactionTarget, action: action)
        fullScreenGes.delegate = self
        targetView.addGestureRecognizer(fullScreenGes)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        //当在根控制器时,由于还没有push,所以viewControllers.count等于0
        if viewControllers.count > 0 { viewController.hidesBottomBarWhenPushed = true }
        super.pushViewController(viewController, animated: animated)
    }
}


//UIGestureRecognizerDelegate
extension UNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let isLeftToRight = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
        //判断是否为侧滑手势
        guard let ges = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        //控制侧滑手势的禁用
        if ges.translation(in: gestureRecognizer.view).x * (isLeftToRight ? 1 : -1) <= 0 || disablePopGesture {
            return false
        }
        return viewControllers.count != 1
    }
}

//导航栏样式
enum UNavigationBarStyle {
    case theme
    case clear
    case white
}

extension UINavigationController {
    private struct AssociatedKeys {
        static var disablePopGesture: Void?    //类属性
    }
    
    //全屏侧滑手势是否有效
    var disablePopGesture: Bool {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.disablePopGesture) as? Bool ?? false)
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.disablePopGesture, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    //设置导航栏样式
    func barStyle(_ style: UNavigationBarStyle) {
        switch style {
        case .theme:
            navigationBar.barStyle = .black       //黑色半透明背景,白色文字
            navigationBar.setBackgroundImage(UIImage(named: "nav_bg"), for: .default)
            navigationBar.shadowImage = UIImage()
        case .white:
            navigationBar.barStyle = .default     //白色半透明背景,黑色文字
            navigationBar.setBackgroundImage(UIColor.white.image(), for: .default)
            navigationBar.shadowImage = nil
        case .clear:
            navigationBar.barStyle = .black
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
        }
    }
}


