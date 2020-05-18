//
//  UNoticeBar.swift
//  Cartoon
//
//  Created by feibi on 2020/5/18.
//  Copyright © 2020 hzbojin. All rights reserved.
//

import UIKit

public enum UNoticeBarStyle {
    case onStatusBar
    case onNavigationBar
}

extension UNoticeBarStyle {
    fileprivate func noticeBarProperties() -> UNoticeBarProperties {
        let screenWidth = UIScreen.main.bounds.width
        
        var properties: UNoticeBarProperties
        switch self {
        case .onNavigationBar:
            properties = UNoticeBarProperties(shadowOffsetY: 3,
                                              fontSizeScaleFactor: 0.55,
                                              textFont: UIFont.systemFont(ofSize: 18),
                                              viewFrame: CGRect(origin: .zero, size: CGSize(width: screenWidth, height: 44.0 + UIApplication.shared.statusBarFrame.height)))
        case .onStatusBar:
            properties = UNoticeBarProperties(shadowOffsetY: 2,
                                              fontSizeScaleFactor: 0.75,
                                              textFont: UIFont.systemFont(ofSize: 13),
                                              viewFrame: CGRect(origin: .zero, size: CGSize(width: screenWidth, height: UIApplication.shared.statusBarFrame.height)))
        }
        return properties
    }
    
    fileprivate func noticeBarOriginY(superViewHeight: CGFloat, _ height: CGFloat) -> CGFloat {
        var originY: CGFloat = 0
        switch self {
        case .onNavigationBar:
            originY = UIApplication.shared.statusBarFrame.height + (superViewHeight - UIApplication.shared.statusBarFrame.height - height) * 0.5
        case .onStatusBar:
            originY = (superViewHeight - height) * 0.5
        }
        return originY
    }
    
    fileprivate var beginWindowLevel: UIWindow.Level {
        switch self {
        case .onStatusBar:
            return .statusBar + 1
        default:
            return .normal
        }
    }
    
    fileprivate var endWindowLevel: UIWindow.Level {
        return .normal
    }
}

public enum UNoticeBarAnimationType {
    case top
    case bottom
    case left
    case right
}

extension UNoticeBarAnimationType {
    fileprivate func noticeBarViewTransform(with frame: CGRect) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        switch self {
        case .top:
            transform = CGAffineTransform(translationX: 0, y: -frame.height)
        case .bottom:
            transform = CGAffineTransform(translationX: 0, y: -frame.height)
        case .left:
            transform = CGAffineTransform(translationX: -frame.width, y: 0)
        case .right:
            transform = CGAffineTransform(translationX: frame.width, y: 0)
        }
        return transform
    }
}

public struct UNoticeBarConfig {
    public var title: String?
    public var image: UIImage? = nil
    public var margin: CGFloat = 10.0
    public var textColor: UIColor = UIColor.black
    public var backgroundColor: UIColor = UIColor.white
    public var animationType: UNoticeBarAnimationType = .top
    public var barStyle: UNoticeBarStyle = .onNavigationBar
    
    public init(title: String? = nil,
                image: UIImage? = nil,
                textColor: UIColor = UIColor.white,
                backgroundColor: UIColor = UIColor.orange,
                barStyle: UNoticeBarStyle = .onNavigationBar,
                animationType: UNoticeBarAnimationType = .top) {
        self.title = title
        self.image = image
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.barStyle = barStyle
        self.animationType = animationType
    }
}

fileprivate struct UNoticeBarProperties {
    var shadowOffsetY: CGFloat = 0
    var fontSizeScaleFactor: CGFloat = 0
    var textFont: UIFont = UIFont()
    var viewFrame: CGRect = .zero
    
    init(shadowOffsetY: CGFloat,
         fontSizeScaleFactor: CGFloat,
         textFont: UIFont,
         viewFrame: CGRect) {
        self.shadowOffsetY = shadowOffsetY
        self.fontSizeScaleFactor = fontSizeScaleFactor
        self.textFont = textFont
        self.viewFrame = viewFrame
    }
}

class UNoticeBar: UIView {
    private var config = UNoticeBarConfig()
    
    open var titleLabel: UILabel? {
        return _titleLabel;
    }
    
    open var imageView: UIImageView? {
        return _imageView
    }
   
    private var _titleLabel: UILabel?
    private var _imageView: UIImageView?
    
    public func show(duration: TimeInterval, completed: ((_ finished: Bool) -> Void)? = nil) {
        self.show(duration: duration, willShow: { [weak self] in
            guard let strongSelf = self else { return }
            UIApplication.shared.keyWindow?.windowLevel = strongSelf.config.barStyle.beginWindowLevel
        }, completed: { [weak self] finished in
            guard let strongSelf = self else { return }
            completed?(finished)
            if finished {
                UIApplication.shared.keyWindow?.windowLevel = strongSelf.config.barStyle.endWindowLevel
            }
        })
    }
    
    public init(config: UNoticeBarConfig) {
        super.init(frame: config.barStyle.noticeBarProperties().viewFrame)
        self.backgroundColor = config.backgroundColor
        
        self.config = config
        
        self.layer.shadowOffset = CGSize(width: 0, height: config.barStyle.noticeBarProperties().shadowOffsetY)
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.44
        
        configSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configSubviews() {
        _titleLabel = UILabel()
        _titleLabel?.text = config.title
        _titleLabel?.textColor = config.textColor
        _titleLabel?.minimumScaleFactor = config.barStyle.noticeBarProperties().fontSizeScaleFactor
        _titleLabel?.adjustsFontSizeToFitWidth = true
        _titleLabel?.font = config.barStyle.noticeBarProperties().textFont
        addSubview(_titleLabel!)
        
        var titleLabelOriginX: CGFloat = 0
        var titleLabelOriginY: CGFloat = 0
        var titleLabelHeight: CGFloat = 0
        var titleLabelWidth: CGFloat = 0
        
        if let image = config.image, config.barStyle != .onStatusBar {
            
            _imageView = UIImageView(image: image)
            _imageView?.contentMode = .scaleAspectFill
            addSubview(_imageView!)
            
            let imageViewWidth: CGFloat = 25
            let imageViewOriginX = config.margin + 10
            let imageViewOriginY = config.barStyle.noticeBarOriginY(superViewHeight: frame.height, imageViewWidth)
            _imageView?.frame = CGRect(origin: CGPoint(x: imageViewOriginX, y: imageViewOriginY),
                                       size: CGSize(width: imageViewWidth, height: imageViewWidth))
            
            titleLabelOriginX = _imageView!.frame.maxX + config.margin
            titleLabelOriginY = _imageView!.frame.origin.y
            titleLabelHeight = _imageView!.frame.size.height
            titleLabelWidth = UIScreen.main.bounds.width - titleLabelOriginX - config.margin
            _titleLabel?.textAlignment = .left
            
        } else {
            _titleLabel?.textAlignment = .center
            
            titleLabelHeight = 25
            titleLabelWidth = UIScreen.main.bounds.width - 2 * config.margin
            titleLabelOriginX = config.margin
            titleLabelOriginY = config.barStyle.noticeBarOriginY(superViewHeight: frame.height, titleLabelHeight)
        }
        
        _titleLabel?.frame = CGRect(x: titleLabelOriginX, y: titleLabelOriginY, width: titleLabelWidth, height: titleLabelHeight)
    }
    
    private func show(duration: TimeInterval, willShow: () -> Void, completed: ((_ finished: Bool) -> Void)?) {
        if let subViews = UIApplication.shared.keyWindow?.subviews {
            for view in subViews {
                if view.isKind(of: UNoticeBar.self) {
                    view.removeFromSuperview()
                }
            }
        }
        
        willShow()
        
        UIApplication.shared.keyWindow?.addSubview(self)
        self.transform = config.animationType.noticeBarViewTransform(with: frame)
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                UIView.animate(withDuration: 0.4, animations: {
                    self.transform = self.config.animationType.noticeBarViewTransform(with: self.frame)
                }) { _ in
                    self.removeFromSuperview()
                }
            }
        }
    }
}
