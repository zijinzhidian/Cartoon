//
//  UReadViewController.swift
//  Cartoon
//
//  Created by apple on 2018/12/29.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

class UReadViewController: UBaseViewController {
    // MARK: Property
    private var chapterList = [ChapterModel]()
    private var detailStatic: DetailStaticModel?
    private var selectIndex: Int = 0
    private var previousIndex: Int = 0
    private var nextIndex: Int = 0
    
    private var edgeInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets
        } else {
            return .zero
        }
    }
    
    private var isBarHidden: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.5) {
                self.topBar.snp.updateConstraints {
                    $0.top.equalTo(self.backScrollView).offset(self.isBarHidden ? -(self.edgeInsets.top + 44) : 0)
                }
            }
        }
    }
    
    // MARK: Getter
    private lazy var backScrollView: UIScrollView = {
        let bs = UIScrollView()
        bs.delegate = self
        bs.minimumZoomScale = 1.0
        bs.maximumZoomScale = 1.5
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction))
        singleTap.numberOfTapsRequired = 1
        bs.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        doubleTap.numberOfTapsRequired = 2
        bs.addGestureRecognizer(doubleTap)
        singleTap.require(toFail: doubleTap)
        return bs
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let cw = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cw.backgroundColor = UIColor.background
        cw.delegate = self
        cw.dataSource = self
        cw.register(cellType: UReadCCell.self)
        cw.uHead = URefreshAutoHeader { [weak self] in
            let previousIndex = self?.previousIndex ?? 0
            self?.loadData(with: previousIndex, isPreious: true, needClear: false, finished: { [weak self] (finish) in
                self?.previousIndex = previousIndex - 1
            })
        }
        cw.uFoot = URefreshAutoFooter { [weak self] in
            let nextIndex = self?.nextIndex ?? 0
            self?.loadData(with: nextIndex, isPreious: false, needClear: false, finished: { [weak self] (finish) in
                self?.nextIndex = nextIndex + 1
            })
        }
        return cw
    }()
    
    lazy var topBar: UReadTopBar = {
        let tr = UReadTopBar()
        tr.backgroundColor = UIColor.white
        tr.backButton.addTarget(self, action: #selector(pressBack), for: .touchUpInside)
        return tr
    }()
    
    // MARK: Init
    convenience init(detailStatic: DetailStaticModel?, selectIndex: Int) {
        self.init()
        self.detailStatic = detailStatic
        self.selectIndex = selectIndex
        self.previousIndex = selectIndex - 1
        self.nextIndex = selectIndex + 1
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData(with: selectIndex, isPreious: false, needClear: false)
    }
    
    // MARK: LoadData
    func loadData(with index: Int, isPreious: Bool, needClear: Bool, finished: ((_ finished: Bool) -> Void)? = nil) {
        guard let detailStatic = detailStatic else { return }
        topBar.titleLabel.text = detailStatic.comic?.name
        
        if index <= -1 {
            collectionView.uHead?.endRefreshing()
            UNoticeBar(config: UNoticeBarConfig(title: "亲,这已经是第一页了")).show(duration: 2)
        } else if index >= detailStatic.chapter_list?.count ?? 0 {
            collectionView.uFoot?.endRefreshingWithNoMoreData()
            UNoticeBar(config: UNoticeBarConfig(title: "亲,已经木有了")).show(duration: 2)
        } else {
            guard let chapterId = detailStatic.chapter_list?[index].chapter_id else { return }
            ApiLoadingProvider.request(UApi.chapter(chapter_id: chapterId), model: ChapterModel.self) { (returnData) in
                guard let chapter = returnData else { return }
                if needClear { self.chapterList.removeAll() }
                if isPreious {
                    self.chapterList.insert(chapter, at: 0)
                } else {
                    self.chapterList.append(chapter)
                }
                self.collectionView.reloadData()
                guard let finished = finished else { return }
                finished(true)
            }
        }
    }
    
    // MARK: Private_M
    override func configUI() {
        view.backgroundColor = UIColor.white
        
        view.addSubview(backScrollView)
        backScrollView.snp.makeConstraints {
            $0.edges.equalTo(self.view.usnp.edges)
        }
        
        backScrollView.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.height.equalToSuperview()
        }
        
        view.addSubview(topBar)
        topBar.snp.makeConstraints {
            $0.top.left.right.equalTo(backScrollView)
            $0.height.equalTo(44)
        }
    }
    
    override func configNavigationBar() {
        super.configNavigationBar()
        navigationController?.barStyle(.white)
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav_back_black"), style: .plain, target: self, action: #selector(pressBack))
        navigationController?.disablePopGesture = true
    }
    
    @objc private func singleTapAction() {
        isBarHidden = !isBarHidden
    }
    
    @objc private func doubleTapAction() {
        var zoomScale = backScrollView.zoomScale
        zoomScale = 2.5 - zoomScale
        let width = view.frame.width / zoomScale
        let height = view.frame.height / zoomScale
        let zoomRect = CGRect(x: backScrollView.center.x - width / 2, y: backScrollView.center.y - height / 2, width: width, height: height)
        backScrollView.zoom(to: zoomRect, animated: true)
    }
}

extension UReadViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return chapterList.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chapterList[section].image_list?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: UReadCCell.self)
        cell.model = chapterList[indexPath.section].image_list?[indexPath.row]
        return cell
    }
}

extension UReadViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let image = chapterList[indexPath.section].image_list?[indexPath.row] else { return CGSize.zero }
        let width = backScrollView.frame.width
        let height = floor(width / CGFloat(image.width) * CGFloat(image.height))
        return CGSize(width: width, height: height)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView == backScrollView {
            return collectionView
        } else {
            return nil
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView == backScrollView {
            scrollView.contentSize = CGSize(width: scrollView.frame.width * scrollView.zoomScale, height: scrollView.frame.height)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isBarHidden == false { isBarHidden = true }
    }
}
