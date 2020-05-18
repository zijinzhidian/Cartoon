//
//  URefresh.swift
//  Cartoon
//
//  Created by apple on 2018/11/5.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit
import MJRefresh

extension UIScrollView {
    var uHead: MJRefreshHeader? {
        get { return mj_header }
        set { mj_header = newValue }
    }
    
    var uFoot: MJRefreshFooter? {
        get { return mj_footer }
        set { mj_footer = newValue }
    }
}

class URefreshHeader: MJRefreshGifHeader {
    override func prepare() {
        super.prepare()
        setImages([UIImage(named: "refresh_normal")!], for: .idle)
        setImages([UIImage(named: "refresh_will_refresh")!], for: .pulling)
        setImages([UIImage(named: "refresh_loading_1")!,
                   UIImage(named: "refresh_loading_2")!,
                   UIImage(named: "refresh_loading_3")!], for: .refreshing)
        lastUpdatedTimeLabel?.isHidden = true
        stateLabel?.isHidden = true
    }
}

class URefreshAutoHeader: MJRefreshHeader {}

class URefreshAutoFooter: MJRefreshAutoFooter {}

class URefreshFooter: MJRefreshBackNormalFooter {}

class URefreshTipKissFooter: MJRefreshBackFooter {
    private lazy var tipLabel: UILabel = {
        let tl = UILabel()
        tl.textAlignment = .center
        tl.textColor = UIColor.lightGray
        tl.font = UIFont.systemFont(ofSize: 14)
        tl.numberOfLines = 0
        return tl
    }()
    
    private lazy var imageView: UIImageView = {
        let iw = UIImageView(image: UIImage(named: "refresh_kiss"))
        return iw
    }()
    
    override func prepare() {
        super.prepare()
        backgroundColor = UIColor.background
        mj_h = 240
        addSubview(tipLabel)
        addSubview(imageView)
    }
    
    override func placeSubviews() {
        tipLabel.frame = CGRect(x: 0, y: 10, width: bounds.width, height: 60)
        imageView.frame = CGRect(x: (bounds.width - 80) / 2, y: 80, width: 80, height: 80)
    }
    
    convenience init(with tip: String) {
        self.init()
        refreshingBlock = { self.endRefreshing() }
        tipLabel.text = tip
    }
}
