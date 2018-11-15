//
//  UPageViewController.swift
//  有妖气漫画
//
//  Created by apple on 2018/10/31.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit
import HMSegmentedControl

enum UPageStyle {
    case none
    case navigationBarSegment
    case topTabBar
}

class UPageViewController: UBaseViewController {
    var pageStyle: UPageStyle!
    
    lazy var segment: HMSegmentedControl = {
        return HMSegmentedControl().then {
            $0.addTarget(self, action: #selector(changeIndex(segment:)), for: .valueChanged)
        }
    }()
    
    lazy var pageVC: UIPageViewController = {
       return UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }()
    
    private(set) var vcs: [UIViewController]!
    private(set) var titles: [String]!
    private var currentSelectIndex: Int = 0
    
    convenience init(titles: [String] = [], vcs: [UIViewController] = [], pageStyle: UPageStyle = .none) {
        self.init()
        self.titles = titles
        self.vcs = vcs
        self.pageStyle = pageStyle
    }
    
    @objc func changeIndex(segment: UISegmentedControl) {
        let index = segment.selectedSegmentIndex
        if currentSelectIndex != index {
            let target: [UIViewController] = [vcs[index]]
            pageVC.setViewControllers(target, direction: .forward, animated: false) { [weak self] (finish) in
                self?.currentSelectIndex = index
            }
        }
    }
    
    override func configUI() {
        guard let vcs = vcs else { return }
        
        addChild(pageVC)
        view.addSubview(pageVC.view)
        
        pageVC.delegate = self
        pageVC.dataSource = self
        pageVC.setViewControllers([vcs[0]], direction: .forward, animated: false, completion: nil)
        
        switch pageStyle {
        case .none:
            pageVC.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        case .navigationBarSegment?:
            pageVC.view.snp.makeConstraints { $0.edges.equalToSuperview() }
            navigationItem.titleView = segment
            segment.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 120, height: 40)
            segment.backgroundColor = UIColor.clear
            //下划线样式
            segment.selectionIndicatorLocation = .none
            //文字样式
            segment.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]
            //选中文字样式
            segment.selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]
        
        case .topTabBar?:
            //文字样式
            segment.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
            //选中文字样式
            segment.selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(r: 127, g: 221, b: 146), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
            //下划线位置
            segment.selectionIndicatorLocation = .down
            //下划线颜色
            segment.selectionIndicatorColor = UIColor(r: 127, g: 221, b: 146)
            //下划线高度
            segment.selectionIndicatorHeight = 2
            //边框样式
            segment.borderType = .bottom
            //边框颜色
            segment.borderColor = UIColor.lightGray
            //边框宽度
            segment.borderWidth = 0.5
            
            view.addSubview(segment)
            segment.snp.makeConstraints {
                $0.top.left.right.equalToSuperview()
                $0.height.equalTo(40)
            }
            pageVC.view.snp.makeConstraints {
                $0.top.equalTo(segment.snp.bottom)
                $0.left.bottom.right.equalToSuperview()
            }
        
        default:
            break
        }
        
        guard let titles = titles else { return }
        segment.sectionTitles = titles
        segment.selectedSegmentIndex = currentSelectIndex
        
    }
}

extension UPageViewController: UIPageViewControllerDataSource {
    //返回前一个控制器
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = vcs.firstIndex(of: viewController) else { return nil }   //当前控制器下标
        let beforeIndex = index - 1
        guard beforeIndex >= 0 else { return nil }      //若前一个控制器不存在返回nil
        return vcs[beforeIndex]
    }
    
    //返回后一个控制器
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = vcs.firstIndex(of: viewController) else { return nil }
        let afterIndex = index + 1
        guard afterIndex <= vcs.count - 1 else { return nil }
        return vcs[afterIndex]
    }
}


extension UPageViewController: UIPageViewControllerDelegate {
    //动画指定完毕后调用
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewController = pageViewController.viewControllers?.last,
            let index = vcs.firstIndex(of: viewController) else { return }
        currentSelectIndex = index
        segment.setSelectedSegmentIndex(UInt(index), animated: true)
        guard titles != nil && pageStyle == .none else { return }
        navigationItem.title = titles[index]
    }
}
