//
//  UCollectionViewAlignedLayout.swift
//  Cartoon
//
//  Created by apple on 2018/11/12.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

protocol Alignment {}

public enum HorizontalAlignment: Alignment{
    case left
    case justified
    case right
}

public enum VerticalAlignment: Alignment {
    case top
    case center
    case bottom
}

//A是类型,Alignment是类型约束,规定了A类型必须遵守Alignment协议
private struct AlignmentAxis<A: Alignment> {
    let alignment: A
    let position: CGFloat
}

class UCollectionViewAlignedLayout: UICollectionViewFlowLayout {
    
    //水平对齐样式
    public var horizontalAlignment: HorizontalAlignment = .justified
    
    //垂直对齐样式
    public var verticalAlignment: VerticalAlignment = .center
    
    //collectionView内容宽度
    private var contentWidth: CGFloat? {
        guard let collectionViewWidth = collectionView?.frame.size.width else { return nil }
        return collectionViewWidth - sectionInset.left - sectionInset.right
    }
    
    //水平方向的布局
    fileprivate var horizontalAlignmentAxis: AlignmentAxis<HorizontalAlignment>? {
        switch horizontalAlignment {
        case .left:
            return AlignmentAxis(alignment: HorizontalAlignment.left, position: sectionInset.left)
        case .right:
            guard let collectionViewWidth = collectionView?.frame.size.width else { return nil }
            return AlignmentAxis(alignment: HorizontalAlignment.right, position: collectionViewWidth - sectionInset.right)
        default:
            return nil
        }
    }
    
    //垂直方向的布局
    fileprivate func verticalAlignmentAxis(for currentLayoutAttributes: UICollectionViewLayoutAttributes) -> AlignmentAxis<VerticalAlignment> {
        let layoutAttributesInLine = layoutAttributes(forItemsInLineWith: currentLayoutAttributes)
        return verticalAlignmentAxisForLine(with: layoutAttributesInLine)!
    }
    
    //每行的垂直方向的布局
    fileprivate func verticalAlignmentAxisForLine(with layoutAttributesInLine: [UICollectionViewLayoutAttributes]) -> AlignmentAxis<VerticalAlignment>? {
        
        guard let firstAttribute = layoutAttributesInLine.first else { return nil }
        
        switch verticalAlignment {
        case .top:
            let minY = layoutAttributesInLine.reduce(CGFloat.greatestFiniteMagnitude) { min($0, $1.frame.minY) }
            return AlignmentAxis(alignment: .top, position: minY)
        
        case .bottom:
            let maxY = layoutAttributesInLine.reduce(0) { max($0, $1.frame.maxY) }
            return AlignmentAxis(alignment: .bottom, position: maxY)
        
        case .center:
            let centerY = firstAttribute.center.y
            return AlignmentAxis(alignment: .center, position: centerY)
        }
        
    }
    
    public init(horizontalAlignment: HorizontalAlignment = .justified, verticalAlignment: VerticalAlignment = .center) {
        super.init()
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //自定义所有可视rect内的布局
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let layoutAttributesObjects = copyAttributesArray(super.layoutAttributesForElements(in: rect))
        layoutAttributesObjects?.forEach({ (layoutAttributes) in
            setFrame(forLayoutAttributes: layoutAttributes)
        })
        return layoutAttributesObjects
        
    }
    
    //自定义item的布局
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else { return nil }
        
        if horizontalAlignment != .justified {
            layoutAttributes.alignHorizontally(collectionViewLayout: self)
        }
        
        if verticalAlignment != .center {
            layoutAttributes.alignVertically(collectionViewLayout: self)
        }
        
        return layoutAttributes
        
    }
    
    //根据indexPath获取原始布局属性
    fileprivate func originalLayoutAttribute(forItemAt indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.layoutAttributesForItem(at: indexPath)
    }
    
    //根据当前item的布局属性,获取该行的布局属性
    fileprivate func layoutAttributes(forItemsInLineWith layoutattributes: UICollectionViewLayoutAttributes) -> [UICollectionViewLayoutAttributes] {
        guard let lineWidth = contentWidth else { return [layoutattributes] }
        var lineFrame = layoutattributes.frame
        lineFrame.origin.x = sectionInset.left
        lineFrame.size.width = lineWidth
        return super.layoutAttributesForElements(in: lineFrame) ?? []
    }
    
    //判断行frame是否与指定frame相交,即指定item是否在行内
    fileprivate func isFrameIntersects(for firstItemAttributes: UICollectionViewLayoutAttributes, isSameLineAsFrameFor secondItemAttributes: UICollectionViewLayoutAttributes) -> Bool {
        guard let lineWidth = contentWidth else { return false }
        let firstItemFrame = firstItemAttributes.frame
        let lineFrame = CGRect(x: sectionInset.left,
                               y: firstItemFrame.origin.y,
                               width: lineWidth,
                               height: firstItemAttributes.size.height)
        return lineFrame.intersects(secondItemAttributes.frame)
    }
    
    //重置cell的frame
    fileprivate func setFrame(forLayoutAttributes layoutAttributes: UICollectionViewLayoutAttributes) {
        if layoutAttributes.representedElementCategory == .cell {           //判断是否为cell的布局属性
            let indexPath = layoutAttributes.indexPath
            if let newFrame = layoutAttributesForItem(at: indexPath)?.frame{            //获取新的frame
                layoutAttributes.frame = newFrame
            }
        }
    }
    
    //拷贝布局属性数组,防止出错
    fileprivate func copyAttributesArray(_ layoutAttributesArray: [UICollectionViewLayoutAttributes]?) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributesArray?.map { $0.copy() } as? [UICollectionViewLayoutAttributes]
    }
}


fileprivate extension UICollectionViewLayoutAttributes {
    private var currentSection: Int {
        return indexPath.section
    }
    
    private var currentItem: Int {
        return indexPath.item
    }
    
    //上一个元素下标
    private var precedingIndexPath: IndexPath {
        return IndexPath(item: currentItem - 1, section: currentSection)
    }
    
    //下一个元素下标
    private var followingIndexPath: IndexPath {
        return IndexPath(item: currentItem + 1, section: currentSection)
    }
    
    
    //是否为行内的第一个item(原理:判断当前item的行frame,是否与上一个item的frame相交,若相交则还是在同一行内,若不相交则是换行的第一个元素)
    func isFirstItemInLine(collectionViewLayout: UCollectionViewAlignedLayout) -> Bool {
        if currentItem <= 0 {
            return true
        } else {
            if let layoutAttributesForPrecedingItem = collectionViewLayout.originalLayoutAttribute(forItemAt: precedingIndexPath) {
                return !collectionViewLayout.isFrameIntersects(for: self, isSameLineAsFrameFor: layoutAttributesForPrecedingItem)
            } else {       //若不存在上一个item则是每组的第一个item
                return true
            }
        }
    }
    
    //是否为行内的最后一个item(原理:判断当前item的行frame,是否与下一个item的frame相交,若相交则还是在同一行内,若不相交则是行内的最后一个元素)
    func isLastItemInLine(collectionViewLayout: UCollectionViewAlignedLayout) -> Bool {
        guard let itemCount = collectionViewLayout.collectionView?.numberOfItems(inSection: currentSection) else { return false }
        
        if currentItem >= itemCount - 1 {
            return true
        } else {
            if let layoutAttributesForFollowingItem = collectionViewLayout.originalLayoutAttribute(forItemAt: followingIndexPath) {
                return !collectionViewLayout.isFrameIntersects(for: self, isSameLineAsFrameFor: layoutAttributesForFollowingItem)
            } else {       //若不存在下一个item则是没组的最后一个item
                return true
            }
        }
    }
    
    //第一个或最后一个item的x坐标
    func alignXForFirstOrLastItem(toAlignmentAxis alignmentAxis: AlignmentAxis<HorizontalAlignment>) {
        switch alignmentAxis.alignment {
        case .left:
            frame.origin.x = alignmentAxis.position
        case .right:
            frame.origin.x = alignmentAxis.position - frame.size.width
        default:
            break
        }
    }
    
    //其它的item的x坐标
    func alignXForOtherItem(alignmentAxis: AlignmentAxis<HorizontalAlignment>, collectionViewLayout: UCollectionViewAlignedLayout) {
        
        let itemSpacing = collectionViewLayout.minimumInteritemSpacing
        
        switch alignmentAxis.alignment {
        case .left:
            if let precedingItemAttributes = collectionViewLayout.layoutAttributesForItem(at: precedingIndexPath) {
                frame.origin.x = precedingItemAttributes.frame.maxX + itemSpacing
            }
        case .right:
            if let followingItemAttributes = collectionViewLayout.layoutAttributesForItem(at: followingIndexPath) {
                frame.origin.x = followingItemAttributes.frame.minX - itemSpacing - frame.size.width
            }
        default:
            break
        }
    }
    
    //item的Y坐标
    func alignYForItem(toAlignmentAxis alignmentAxis: AlignmentAxis<VerticalAlignment>) {
        switch alignmentAxis.alignment {
        case .top:
            frame.origin.y = alignmentAxis.position
        case .bottom:
            frame.origin.y = alignmentAxis.position - frame.size.height
        case .center:
            center.y = alignmentAxis.position
        }
    }
    
    func alignHorizontally(collectionViewLayout: UCollectionViewAlignedLayout) {
        
        guard let alignmentAxis = collectionViewLayout.horizontalAlignmentAxis else { return }
        
        switch collectionViewLayout.horizontalAlignment {
        case .left:
            if isFirstItemInLine(collectionViewLayout: collectionViewLayout) {
                alignXForFirstOrLastItem(toAlignmentAxis: alignmentAxis)
            } else {
                alignXForOtherItem(alignmentAxis: alignmentAxis, collectionViewLayout: collectionViewLayout)
            }
            
        case .right:
            if isLastItemInLine(collectionViewLayout: collectionViewLayout) {
                alignXForFirstOrLastItem(toAlignmentAxis: alignmentAxis)
            } else {
                alignXForOtherItem(alignmentAxis: alignmentAxis, collectionViewLayout: collectionViewLayout)
            }
            
        default:
            return
        }
    }
    
    func alignVertically(collectionViewLayout: UCollectionViewAlignedLayout) {
        let alignmentAxis = collectionViewLayout.verticalAlignmentAxis(for: self)
        alignYForItem(toAlignmentAxis: alignmentAxis)
    }
}
