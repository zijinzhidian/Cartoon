//
//  UCollectionViewSectionBackgroundLayout.swift
//  Cartoon
//
//  Created by apple on 2018/11/2.
//  Copyright © 2018年 hzbojin. All rights reserved.
//


/*给UICollectionView里的Section分别设置不同的背景颜色:
 (1)继承UICollectionReusableView来自定义一个装饰视图(Decoration视图),用来作为各个分组的背景视图
 (2)继承UICollectionViewLayoutAttributes来自定义一个新的布局属性,里面添加一个backgroundColor属性,用来表示Section的背景颜色
 (3)继承UICollectionViewFlowLayout来自定义一个新布局,在这里计算及返回各个分组背景视图的布局属性(位置、尺寸、颜色等)
 (4)新增一个协议方法,使得section背景色可以在外面通过数据源来设置
 */


import UIKit

private let SectionBackground = "UCollectionReusableView"

//增加自己的协议方法,使其可以像cell那样根据数据源来设置section背景色
protocol UCollectionViewSectionBackgroundLayoutDelegateLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        backgroundColorForSectionAt section: Int) -> UIColor
}

//协议扩展:通过扩展提供方法的实现,这样就无需在每个遵循协议的类型中重复同样的实现,会自动获得这个扩展所增加的方法实现
extension UCollectionViewSectionBackgroundLayoutDelegateLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        backgroundColorForSectionAt section: Int) -> UIColor {
        return collectionView.backgroundColor ?? UIColor.clear
    }
}

//定义一个UICollectionViewLayoutAttributes子类作为section背景的布局属性
private class UCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    //默认背景色
    var backgroundColor = UIColor.white
    
    //由于layout attributes对象可能会被collection view复制,所以layout attributes对象应该遵循NSCoping协议，并实现copyWithZone:方法，否则我们获取的自定义属性会一直是空值
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! UCollectionViewLayoutAttributes
        copy.backgroundColor = self.backgroundColor
        return copy
    }
    
    //如果UICollectionViewLayoutAttributes的属性值没有改变,collection view不会应用layout attributes,这些layout attributes的是否改变由isEqual:的返回值来决定,所以必须实现isEqual:方法来比较自定义属性
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? UCollectionViewLayoutAttributes else { return false }
        if !self.backgroundColor.isEqual(rhs.backgroundColor) {
            return false
        }
        return super.isEqual(object)
    }
}

//继承UICollectionReusableView来自定义一个装饰视图,用于作为section背景
private class UCollectionReusableView: UICollectionReusableView {
    //通过apply方法让自定义属性生效
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        guard let attr = layoutAttributes as? UCollectionViewLayoutAttributes else { return }
        
        self.backgroundColor = attr.backgroundColor
    }
}

//自定义布局
class UCollectionViewSectionBackgroundLayout: UICollectionViewFlowLayout {
    //保存所有自定义的section背景的布局属性
    private var decorationViewAttrs: [UICollectionViewLayoutAttributes] = []
    
    override init() {
        super.init()
        setup()
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        //注册自定义用来作为Section背景的装饰视图DecorationView
        self.register(UCollectionReusableView.classForCoder(), forDecorationViewOfKind: SectionBackground)
    }
    
    override func prepare() {
        super.prepare()
        //若当前没有分区则返回
        guard let numberOfSections = self.collectionView?.numberOfSections else { return }
        //若未实现代理则返回
        guard let delegate = self.collectionView?.delegate as? UCollectionViewSectionBackgroundLayoutDelegateLayout else { return }
        
        //先删除原来的section背景的布局属性
        self.decorationViewAttrs.removeAll()
        
        //分别计算每个section背景的布局属性
        for section in 0..<numberOfSections {
            let indexPath = IndexPath(item: 0, section: section)
            
            //获取该section下第一个和最后一个item的布局属性
            guard let numberOfItems = self.collectionView?.numberOfItems(inSection: section),
                numberOfItems > 0,
                let firstItemAttr = self.layoutAttributesForItem(at: indexPath),
                let lastItemAttr = self.layoutAttributesForItem(at: IndexPath(item: numberOfItems - 1, section: section))
                else {
                    continue
            }
            
            //获取该section的内边距
            var sectionInset = self.sectionInset        //UICollectionViewFlowLayout设置
            if let delegateInset = delegate.collectionView?(self.collectionView!, layout: self, insetForSectionAt: section) {   //代理设置
                sectionInset = delegateInset
            }
            
            //获取组头组尾的布局
            let headLayout = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)
            let footLayout = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: indexPath)
            
            //计算该section实际的位置
            var sectionFrame = firstItemAttr.frame.union(lastItemAttr.frame)
            sectionFrame.origin.x = sectionInset.left
            sectionFrame.origin.y -= sectionInset.top
            
            //计算该section实际的尺寸
            if self.scrollDirection == .horizontal {
                sectionFrame.origin.y -= headLayout?.frame.height ?? 0
                sectionFrame.size.width += sectionInset.left + sectionInset.right
                sectionFrame.size.height = (collectionView?.frame.height ?? 0) + (headLayout?.frame.height ?? 0) + (footLayout?.frame.height ?? 0)
            } else {
                sectionFrame.origin.y -= headLayout?.frame.height ?? 0
                sectionFrame.size.width = collectionView?.frame.width ?? 0
                sectionFrame.size.height += sectionInset.top + sectionInset.bottom + (headLayout?.frame.height ?? 0) + (footLayout?.frame.height ?? 0)
            }
            
            //根据上面的结果计算section背景的布局属性
            let attr = UCollectionViewLayoutAttributes(forDecorationViewOfKind: SectionBackground, with: IndexPath(item: 0, section: section))
            attr.frame = sectionFrame
            attr.zIndex = -1
            //通过代理方法获取该section背景使用的颜色
            attr.backgroundColor = delegate.collectionView(self.collectionView!, layout: self, backgroundColorForSectionAt: section)
            
            self.decorationViewAttrs.append(attr)
        }
    }
    
    //返回rect范围内的所有元素的布局属性
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attrs = super.layoutAttributesForElements(in: rect)
        attrs?.append(contentsOf: decorationViewAttrs.filter {
            return rect.intersects($0.frame)
        })
        return attrs
    }
    
    //返回对应于indexPath的位置的Decoration视图的布局属性
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //如果是自定义的Decoration视图,则返回它的布局属性
        if elementKind == SectionBackground {
            return self.decorationViewAttrs[indexPath.section]
        }
        return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    }
}

