//
//  UComicViewController.swift
//  Cartoon
//
//  Created by apple on 2018/11/13.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

class UComicViewController: UBaseViewController {
    
    private var comicid: Int = 0
    
    private var detailStatic: DetailStaticModel?
    private var detailRealtime: DetailRealtimeModel?
    
    private lazy var navigationBarY: CGFloat = {
        return navigationController?.navigationBar.frame.maxY ?? 0
    }()
    
    private lazy var mainScrollView: UIScrollView = {
        let sw = UIScrollView()
        return sw
    }()

    private lazy var headView: UComicHead = {
        return UComicHead(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: navigationBarY + 150))
    }()
    
    private lazy var pageVC: UPageViewController = {
        return UPageViewController(titles: ["详情", "目录", "评论"],
                                   vcs: [detailVC, chapterVC, commontVC],
                                   pageStyle: .topTabBar)
    }()
    
    private lazy var detailVC: UBaseViewController = {
        let dc = UBaseViewController()
        return dc
    }()
    
    private lazy var chapterVC: UBaseViewController = {
        let cc = UBaseViewController()
        cc.view.backgroundColor = UIColor.red
        return cc
    }()
    
    private lazy var commontVC: UBaseViewController = {
        let cc = UBaseViewController()
        return cc
    }()
    
    convenience init(comicid: Int) {
        self.init()
        self.comicid = comicid
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func configUI() {
        
        view.addSubview(mainScrollView)
        mainScrollView.snp.makeConstraints {
//            $0.edges.equalTo(self.view.usnp.edges).priority(.low)
//            $0.top.equalToSuperview()
            $0.edges.equalToSuperview()
        }
        
        let contentView = UIView()
        contentView.backgroundColor = UIColor.red
        mainScrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            //不知道为什么需要设置width和height的自定布局才会显示
            $0.width.equalToSuperview()
            $0.height.equalToSuperview().offset(-navigationBarY)
        }
        
//        addChild(pageVC)
//        contentView.addSubview(pageVC.view)
//        pageVC.view.snp.makeConstraints { $0.edges.equalToSuperview() }
//        
        mainScrollView.parallaxHeader.view = headView
        mainScrollView.parallaxHeader.height = navigationBarY + 150
        mainScrollView.parallaxHeader.minimumHeight = navigationBarY
        mainScrollView.parallaxHeader.mode = .fill
    }
    
    override func configNavigationBar() {
        super.configNavigationBar()
        navigationController?.barStyle(.clear)
//        mainScrollView.contentOffset = CGPoint(x: 0, y: -navigationBarY - 150)
//        mainScrollView.contentOffset = CGPoint(x: 0, y: -mainScrollView.parallaxHeader.height)
//        mainScrollView.contentInset = UIEdgeInsets(top: -navigationBarY, left: 0, bottom: 0, right: 0)
        
    }
    
    private func loadData() {
        ApiLoadingProvider.request(UApi.detailStatic(comicid: comicid), model: DetailStaticModel.self) { [weak self] (detailStatic) in
            self?.detailStatic = detailStatic
            self?.headView.detailStatic = detailStatic?.comic
        }
        
        ApiProvider.request(UApi.detailRealtime(comicid: comicid), model: DetailRealtimeModel.self) { [weak self] (detailRealtime) in
            self?.detailRealtime = detailRealtime
            self?.headView.detailRealtime = detailRealtime?.comic
        }
    }
    
}
