//
//  UIScrollView+ParallaxHeader.swift
//  Cartoon
//
//  Created by apple on 2018/11/14.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    private struct AssociatedKeys {
        static var descriptiveName = "AssociatedKeys.DescriptiveName.parallaxHeader"
    }
    
    public var parallaxHeader: ParallaxHeader {
        get {
            if let header = objc_getAssociatedObject(self, &AssociatedKeys.descriptiveName) as? ParallaxHeader {
                return header
            }
            let header = ParallaxHeader()
            self.parallaxHeader = header
            return header
        }
        
        set(parallaxHeader) {
            parallaxHeader.scrollView = self
            objc_setAssociatedObject(self, &AssociatedKeys.descriptiveName, parallaxHeader, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
