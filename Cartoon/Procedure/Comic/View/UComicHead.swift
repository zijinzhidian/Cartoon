//
//  UComicHead.swift
//  Cartoon
//
//  Created by apple on 2018/11/13.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

class UComicHeadCCell: UBaseCollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        let tl = UILabel()
        tl.textColor = UIColor.white
        tl.textAlignment = .center
        tl.font = UIFont.systemFont(ofSize: 14)
        return tl
    }()
    
    override func configUI() {
        layer.cornerRadius = 3
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

private let kComicHeadCCellID = "comicHeadCCellID"

class UComicHead: UIView {
    
    private var themes: [String]?
    
    private lazy var bgView: UIImageView = {
        let bw = UIImageView()
        bw.contentMode = .scaleAspectFill
        bw.blurView.setup(style: .dark, alpha: 1).enable()
        return bw
    }()
    
    private lazy var coverView: UIImageView = {
        let cw = UIImageView()
        cw.contentMode = .scaleAspectFill
        cw.layer.cornerRadius = 3
        cw.layer.borderWidth = 1
        cw.layer.borderColor = UIColor.white.cgColor
        return cw
    }()
    
    private lazy var nameLabel: UILabel = {
        let nl = UILabel()
        nl.textColor = UIColor.white
        nl.font = UIFont.systemFont(ofSize: 16)
        return nl
    }()
    
    private lazy var authorLabel: UILabel = {
        let al = UILabel()
        al.textColor = UIColor.white
        al.font = UIFont.systemFont(ofSize: 13)
        return al
    }()
    
    private lazy var totalLabel: UILabel = {
        let tl = UILabel()
        tl.textColor = UIColor.white
        tl.font = UIFont.systemFont(ofSize: 13)
        return tl
    }()
    
    private lazy var themeView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: 40, height: 20)
        layout.scrollDirection = .horizontal
        let cw = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cw.backgroundColor = UIColor.clear
        cw.dataSource = self
        cw.register(UComicHeadCCell.self, forCellWithReuseIdentifier: kComicHeadCCellID)
        return cw
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        addSubview(bgView)
        bgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bgView.addSubview(coverView)
        coverView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-20)
            $0.width.equalTo(90)
            $0.height.equalTo(120)
        }
        
        bgView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.left.equalTo(coverView.snp.right).offset(20)
            $0.right.greaterThanOrEqualToSuperview().offset(-20)
            $0.top.equalTo(coverView)
            $0.height.equalTo(20)
        }
        
        bgView.addSubview(authorLabel)
        authorLabel.snp.makeConstraints {
            $0.left.height.equalTo(nameLabel)
            $0.right.greaterThanOrEqualToSuperview().offset(-20)
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
        }
        
        bgView.addSubview(totalLabel)
        totalLabel.snp.makeConstraints {
            $0.left.height.equalTo(authorLabel)
            $0.right.greaterThanOrEqualToSuperview().offset(-20)
            $0.top.equalTo(authorLabel.snp.bottom).offset(10)
        }
        
        bgView.addSubview(themeView)
        themeView.snp.makeConstraints {
            $0.left.equalTo(totalLabel)
            $0.height.equalTo(30)
            $0.right.greaterThanOrEqualToSuperview().offset(-20)
            $0.bottom.equalTo(coverView)
        }
    }
    
    var detailStatic: ComicStaticModel? {
        didSet {
            guard let detailStatic = detailStatic else { return }
            bgView.kf.setImage(urlString: detailStatic.cover, placeholder: UIImage(named: "normal_placeholder_v"))
            coverView.kf.setImage(urlString: detailStatic.cover, placeholder: UIImage(named: "normal_placeholder_v"))
            nameLabel.text = detailStatic.name
            authorLabel.text = detailStatic.author?.name
            themes = detailStatic.theme_ids ?? []
            themeView.reloadData()
        }
    }
    
    var detailRealtime: ComicRealtimeModel? {
        didSet {
            guard let detailRealtime = detailRealtime else { return }
            let text = NSMutableAttributedString(string: "点击 收藏")
            text.insert(NSAttributedString(string: " \(detailRealtime.click_total ?? "0")",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.orange, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]), at: 2)
            text.append(NSAttributedString(string: " \(detailRealtime.favorite_total ?? "0")", attributes: [NSAttributedString.Key.foregroundColor: UIColor.orange, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]))
            totalLabel.attributedText = text
        }
    }
    
}

extension UComicHead: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return themes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kComicHeadCCellID, for: indexPath) as! UComicHeadCCell
        cell.titleLabel.text = themes?[indexPath.row]
        return cell
    }
    
}
