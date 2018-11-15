//
//  UIViewExtension.swift
//  Cartoon
//
//  Created by apple on 2018/11/13.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

extension UIView {

    private struct AssocoatedKeys {
        static var descriptiveName = "AssocoatedKeys.DescriptiveName.blurView"
    }
    
    private(set) var blurView: BlurView {
        get {
            if let blurView = objc_getAssociatedObject(self, &AssocoatedKeys.descriptiveName) as? BlurView {
                return blurView
            }
            self.blurView = BlurView(to: self)              //属性观察器里面修改该属性不会再触发属性观察器
            return self.blurView
        }
        
        set(blurView) {
            objc_setAssociatedObject(self, &AssocoatedKeys.descriptiveName, blurView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    class BlurView {
        
        private var superview: UIView               //需要添加毛玻璃效果的视图
        private var blur: UIVisualEffectView?       //毛玻璃效果视图
        private var editing: Bool = false           //毛玻璃效果是否能改变
        private(set) var blurContentView: UIView?
        private(set) var vibrancyContentView: UIView?
        
        var animationDuration: TimeInterval = 0.1   //毛玻璃透明度改变动画时间
        
        var style: UIBlurEffect.Style = .light {        //毛玻璃效果样式(可以改变)
            didSet {
                guard oldValue != style, !editing else { return }
                applyBlurEffect()
            }
        }
        
        var alpha: CGFloat = 0 {         //毛玻璃透明度(可以动画改变)
            didSet {
                guard !editing else { return }
                if blur == nil {
                    applyBlurEffect()
                }
                let alpha = self.alpha
                UIView.animate(withDuration: animationDuration) {
                    self.blur?.alpha = alpha
                }
            }
        }
        
        init(to view: UIView) {
            self.superview = view
        }
        
        func setup(style: UIBlurEffect.Style, alpha: CGFloat) -> Self {
            self.editing = true
            
            self.style = style
            self.alpha = alpha
            
            self.editing = false
            
            return self
        }
      
        /// 开启毛玻璃效果
        ///
        /// - Parameter isHidden: 是否禁用
        func enable(isHidden: Bool = false) {
            if blur == nil {        //若毛玻璃视图为nil,则创建
                applyBlurEffect()
            }
            
            self.blur?.isHidden = isHidden
        }
        
        
        /// 设置毛玻璃效果
        func applyBlurEffect() {
            blur?.removeFromSuperview()
            
            applyBlurEffect(style: style, blurAlpha: alpha)
        }
        
        /// 初始化毛玻璃效果
        ///
        /// - Parameters:
        ///   - style: 毛玻璃样式
        ///   - blurAlpha: 透明度
        private func applyBlurEffect(style: UIBlurEffect.Style, blurAlpha: CGFloat) {
            
            superview.backgroundColor = UIColor.clear
            
            /*
             UIBlurEffect: 模糊效果
             
             UIVibrancyEffect: 主要用于放大和调整 UIVisualEffectView 视图下面的内容的颜色，同时让 UIVisualEffectView 的 contentView 中的内容看起来更加生动
             
             UIVisualEffectView: 模糊视图,将模糊视图置于待毛玻璃花的视图之上即可,在模糊视图下面的所有视图都会有模糊效果
            */
            
            let blurEffect = UIBlurEffect(style: style)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
            let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
            blurEffectView.contentView.addSubview(vibrancyView)
            
            //毛玻璃视图透明度
            blurEffectView.alpha = blurAlpha
            
            //添加毛玻璃视图
            superview.insertSubview(blurEffectView, at: 0)
            
            //自动布局
            blurEffectView.addAlignedConstrains()
            vibrancyView.addAlignedConstrains()
            
            self.blur = blurEffectView
            self.blurContentView = blurEffectView.contentView
            self.vibrancyContentView = vibrancyView.contentView
            
        }
        
    }
    
    private func addAlignedConstrains() {
        translatesAutoresizingMaskIntoConstraints = false
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.top)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.leading)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.trailing)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.bottom)
    }
    
    private func addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute) {
        superview?.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: attribute,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: superview,
                attribute: attribute,
                multiplier: 1,
                constant: 0
            )
        )
    }
    
}
