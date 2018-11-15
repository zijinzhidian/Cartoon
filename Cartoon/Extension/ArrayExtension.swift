//
//  ArrayExtension.swift
//  Cartoon
//
//  Created by apple on 2018/11/3.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

extension Array {
    //截取数组
    public func takeMax(_ n: Int) -> Array {
        return Array(self[0..<Swift.max(0, Swift.min(n, count))])
    }
    
    //检测数组的每个元素,若每个元素都符合条件则返回true
    public func testAll(_ body: @escaping (Element) -> Bool) -> Bool {
        return !contains { !body($0) }
    }
    
    //检测数组里面的元素是否都为true或false
    public func testAll(is condition: Bool) -> Bool {
        return testAll { $0 as? Bool ?? !condition == condition }
    }
}

extension Array where Element: Equatable {
    //移除数组中的元素
    public mutating func removeAll(_ elements: [Element]) {
        self = filter { !elements.contains($0) }
    }
}
