//
//  UComicViewController.swift
//  Cartoon
//
//  Created by apple on 2018/11/13.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

protocol UComicViewWillEndDraggingDelegate: class {
    func comicWillEndDragging(_ scrollView: UIScrollView)
}

class UComicViewController: UBaseViewController {
    
    private var comicid: Int = 0
    
    private var detailStatic: DetailStaticModel?
    private var detailRealtime: DetailRealtimeModel?
    
    private lazy var navigationBarY: CGFloat = {
        return navigationController?.navigationBar.frame.maxY ?? 0
    }()
    
    private lazy var mainScrollView: UIScrollView = {
        let sw = UIScrollView()
        sw.delegate = self
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
    
    private lazy var detailVC: UDetailViewController = {
        let dc = UDetailViewController()
        dc.delegate = self
        return dc
    }()
    
    private lazy var chapterVC: UChapterViewController = {
        let cc = UChapterViewController()
        cc.delegate = self
        return cc
    }()
    
    private lazy var commontVC: UCommentViewController  = {
        let cc = UCommentViewController()
        cc.delegate = self
        return cc
    }()
    
    convenience init(comicid: Int) {
        self.init()
        self.comicid = comicid
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = .top
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        loadData()
    }
    
    override func configUI() {
        
        view.addSubview(mainScrollView)
        mainScrollView.snp.makeConstraints {
            $0.edges.equalTo(self.view.usnp.edges).priority(.low)
            $0.top.equalToSuperview()
        }
        
        let contentView = UIView()
        mainScrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            //不知道为什么需要设置width和height的自定布局才会显示
            $0.width.equalToSuperview()
            $0.height.equalToSuperview().offset(-navigationBarY)
        }
        
        addChild(pageVC)
        contentView.addSubview(pageVC.view)
        pageVC.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        mainScrollView.parallaxHeader.view = headView
        mainScrollView.parallaxHeader.height = navigationBarY + 150
        mainScrollView.parallaxHeader.minimumHeight = navigationBarY
        mainScrollView.parallaxHeader.mode = .fill
    }
    
    override func configNavigationBar() {
        super.configNavigationBar()
        navigationController?.barStyle(.clear)
        mainScrollView.contentOffset = CGPoint(x: 0, y: -mainScrollView.parallaxHeader.height)
    }
    
    private func loadData() {
        
        let group = DispatchGroup()
        
        group.enter()
        ApiLoadingProvider.request(UApi.detailStatic(comicid: comicid), model: DetailStaticModel.self) { [weak self] (detailStatic) in
            self?.detailStatic = detailStatic
            self?.headView.detailStatic = detailStatic?.comic
            
            self?.detailVC.detailStatic = detailStatic
            self?.chapterVC.detailStatic = detailStatic
            self?.commontVC.detailStatic = detailStatic
            
            ApiProvider.request(UApi.commentList(object_id: detailStatic?.comic?.comic_id ?? 0,
                                                 thread_id: detailStatic?.comic?.thread_id ?? 0,
                                                 page: -1),
                                model: CommentListModel.self,
                                completion: { [weak self] (commentList) in
                                    self?.commontVC.commentList = commentList
                                    group.leave()
            })
        }
        
        group.enter()
        ApiProvider.request(UApi.detailRealtime(comicid: comicid), model: DetailRealtimeModel.self) { [weak self] (detailRealtime) in
            self?.detailRealtime = detailRealtime
            self?.headView.detailRealtime = detailRealtime?.comic
            
            self?.detailVC.detailRealtime = detailRealtime
            self?.chapterVC.detailRealtime = detailRealtime
            
            group.leave()
        }
        
        group.enter()
        ApiProvider.request(UApi.guessLike, model: GuessLikeModel.self) { [weak self] (guessLike) in
            self?.detailVC.guessLike = guessLike
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.detailVC.reloadData()
            self.chapterVC.reloadData()
            self.commontVC.reloadData()
        }
    }
    
}

extension UComicViewController: UIScrollViewDelegate, UComicViewWillEndDraggingDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= -scrollView.parallaxHeader.minimumHeight {
            navigationController?.barStyle(.theme)
            navigationController?.title = detailStatic?.comic?.name
        } else {
            navigationController?.barStyle(.clear)
            navigationItem.title = ""
        }
    }
    
    func comicWillEndDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            mainScrollView.setContentOffset(CGPoint(x: 0, y: -mainScrollView.parallaxHeader.minimumHeight), animated: true)
        } else if scrollView.contentOffset.y < 0 {
            mainScrollView.setContentOffset(CGPoint(x: 0, y: -mainScrollView.parallaxHeader.height), animated: true)
        }
    }
}
