//
//  UEmptyDataSet.swift
//  Cartoon
//
//  Created by apple on 2018/11/6.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import Foundation
import EmptyDataSet_Swift

extension UIScrollView {
    private struct AssociatedKeys {
        static var uEmptyKey: Void?
    }
    
    var uEmpty: UEmptyView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.uEmptyKey) as? UEmptyView
        }
        set {
            self.emptyDataSetSource = newValue
            self.emptyDataSetDelegate = newValue
            objc_setAssociatedObject(self, &AssociatedKeys.uEmptyKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

class UEmptyView: EmptyDataSetSource, EmptyDataSetDelegate {
    var image: UIImage?
    
    var allowShow: Bool = false
    var verticalOffset: CGFloat = 0
    
    private var tapClosure: (() -> Void)?
    
    init(image: UIImage? = UIImage(named: "nodata"), verticalOffset: CGFloat = 0, tapClosure: (() -> Void)?) {
        self.image = image
        self.verticalOffset = verticalOffset
        self.tapClosure = tapClosure
    }
    
    //设置垂直偏移量
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return verticalOffset
    }
    
    //设置图片
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return image
    }
    
    //是否显示
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return allowShow
    }
    
    //点击事件
    func emptyDataSet(_ scrollView: UIScrollView, didTapView view: UIView) {
        guard let tapClosure = tapClosure else { return }
        tapClosure()
    }
}
