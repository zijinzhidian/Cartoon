//
//  UBoutiqueListViewController.swift
//  Cartoon
//
//  Created by apple on 2018/11/1.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit
import LLCycleScrollView

private let kComicCCellID = "comicCCellID"
private let kBoardCCellID = "boardCCellID"
private let kComicCHeadID = "comicCHeadID"
private let kComicCFootID = "comicCFootID"

class UBoutiqueListViewController: UBaseViewController {
    
    private var sexType: Int = UserDefaults.standard.integer(forKey: String.sexTypeKey)
    private var galleryItems = [GalleryItemModel]()
    private var textItems = [TextItemModel]()
    private var comicLists = [ComicListModel]()
    
    private lazy var bannerView: LLCycleScrollView = {
        let bw = LLCycleScrollView()
        bw.backgroundColor = UIColor.background
        bw.autoScrollTimeInterval = 6
        bw.placeHolderImage = UIImage(named: "normal_placeholder")
        bw.pageControlPosition = .right
        bw.pageControlBottom = 20
        bw.titleBackgroundColor = UIColor.clear
        bw.lldidSelectItemAtIndex = didSelectBanner(index:)
        return bw
    }()
    
    private lazy var sexTypeButton: UIButton = {
        let sn = UIButton(type: .custom)
        sn.setTitleColor(UIColor.black, for: .normal)
        sn.addTarget(self, action: #selector(changeSex), for: .touchUpInside)
        return sn
    }()
    
    private lazy var collectionView: UICollectionView = {
        let lt = UCollectionViewSectionBackgroundLayout()
        lt.minimumInteritemSpacing = 5
        lt.minimumLineSpacing = 10
        let cw = UICollectionView(frame: CGRect.zero, collectionViewLayout: lt)
        cw.backgroundColor = UIColor.background
        cw.contentInset = UIEdgeInsets(top: UIScreen.main.bounds.width * 0.467, left: 0, bottom: 0, right: 0)
        cw.delegate = self
        cw.dataSource = self
        cw.register(UComicCCell.self, forCellWithReuseIdentifier: kComicCCellID)
        cw.register(UBoardCCell.self, forCellWithReuseIdentifier: kBoardCCellID)
        cw.register(UComicCHead.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: kComicCHeadID)
        cw.register(UComicCFoot.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: kComicCFootID)
        cw.uHead = URefreshHeader { [weak self]  in self?.loadData(false) }
        cw.uEmpty = UEmptyView(verticalOffset: -(cw.contentInset.top), tapClosure: {
            self.loadData(false)
        })
        return cw
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData(false)
    }
    
    override func configUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(bannerView)
        bannerView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(collectionView.contentInset.top)
        }
        
        view.addSubview(sexTypeButton)
        sexTypeButton.snp.makeConstraints {
            $0.width.height.equalTo(60)
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
    
    @objc private func changeSex() {
        loadData(true)
    }
    
    private func loadData(_ changeSex: Bool) {
        if changeSex {
            sexType = 3 - sexType
            UserDefaults.standard.set(sexType, forKey: String.sexTypeKey)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: .USexTypeDidChange, object: nil)
        }
        
        ApiLoadingProvider.request(UApi.boutiqueList(sexType: sexType), model: BoutiqueListModel.self) { [weak self] (returnData) in
            self?.collectionView.uHead.endRefreshing()
            self?.collectionView.uEmpty?.allowShow = true
            
            self?.galleryItems = returnData?.galleryItems ?? []
            self?.textItems = returnData?.textItems ?? []
            self?.comicLists = returnData?.comicLists ?? []
            
            self?.sexTypeButton.setImage(UIImage(named: self?.sexType == 1 ? "gender_male" : "gender_female"), for: .normal)
            
            self?.collectionView.reloadData()
            self?.bannerView.imagePaths = self?.galleryItems.filter { $0.cover != nil }.map{ $0.cover! } ?? []
            
        }
    }
    
    private func didSelectBanner(index: NSInteger) {
        let item = galleryItems[index]
        if item.linkType == 2 {
            guard let url = item.ext?.compactMap({
                return $0.key == "url" ? $0.val : nil
            }).joined() else { return }
            let vc = UBaseWebViewController(url: url)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            print(111111)
//            guard let comicIdString =
        }
    }
}


extension UBoutiqueListViewController: UICollectionViewDataSource {
    //组数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return comicLists.count
    }
    
    //每组个数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let comicList = comicLists[section]
        return comicList.comics?.prefix(4).count ?? 0
    }
    
    //单元格
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let comicList = comicLists[indexPath.section]
        if comicList.comicType == .billboard {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kBoardCCellID, for: indexPath) as! UBoardCCell
            cell.model = comicList.comics?[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kComicCCellID, for: indexPath) as! UComicCCell
            if comicList.comicType == .thematic {
                cell.style = .none
            } else {
                cell.style = .withTitleAndDesc
            }
            cell.model = comicList.comics?[indexPath.row]
            return cell
        }
    }
    
    //组头和组尾
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let head = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: kComicCHeadID, for: indexPath) as! UComicCHead
            let comicList = comicLists[indexPath.section]
            head.iconView.kf.setImage(urlString: comicList.newTitleIconUrl)
            head.titleLabel.text = comicList.itemTitle
            head.moreActionClosure = {
                if comicList.comicType == .thematic {
                    let vc = UPageViewController(titles: ["漫画", "次元"],
                                                 vcs: [USpecialViewController(argCon: 2),
                                                       USpecialViewController(argCon: 4)],
                                                 pageStyle: .navigationBarSegment)
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if comicList.comicType == .animation {
                    let vc = UBaseWebViewController(url: "http://m.u17.com/wap/cartoon/list")
                    vc.title = "动画"
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if comicList.comicType == .update {
                    let vc = UUpdateListViewController(argCon: comicList.argCon,
                                                       argName: comicList.argName,
                                                       argValue: comicList.argValue)
                    vc.title = comicList.itemTitle
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = UComicListViewController(argCon: comicList.argCon,
                                                      argName: comicList.argName,
                                                      argValue: comicList.argValue)
                    vc.title = comicList.itemTitle
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            return head
        } else {
            let foot = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: kComicCFootID, for: indexPath) as! UComicCFoot
            return foot
        }
    }
}

extension UBoutiqueListViewController: UCollectionViewSectionBackgroundLayoutDelegateLayout {
    //设置单元格大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let comicList = comicLists[indexPath.section]
        if comicList.comicType == .billboard {
            let width = floor((screenWidth - 15.0) / 4.0)
            return CGSize(width: width, height: 80)
        } else {
            if comicList.comicType == .thematic {
                let width = floor((screenWidth - 5.0) / 2.0)
                return CGSize(width: width, height: 120)
            } else {
                let count = comicList.comics?.takeMax(4).count ?? 0
                let warp = count % 2 + 2
                let width = floor((screenWidth - CGFloat(warp - 1) * 5.0) / CGFloat(warp))
                return CGSize(width: width, height: CGFloat(warp * 80))
            }
        }
    }
    
    //设置组头大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let comicList = comicLists[section]
        return comicList.itemTitle?.count ?? 0 > 0 ? CGSize(width: screenWidth, height: 44) : CGSize.zero
    }
    
    //设置组尾大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return comicLists.count - 1 != section ? CGSize(width: screenWidth, height: 10) : CGSize.zero
    }
    
    //设置每组的背景颜色
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, backgroundColorForSectionAt section: Int) -> UIColor {
        return UIColor.white
    }
    
    //单元格点击事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let comicList = comicLists[indexPath.section]
        guard let item = comicList.comics?[indexPath.row] else { return }
        
        if comicList.comicType == .billboard {
            let vc = UComicListViewController(argName: item.argName, argValue: item.argValue)
            vc.title = item.name
            navigationController?.pushViewController(vc, animated: true)
        } else {
            
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            bannerView.snp.updateConstraints {
                $0.top.equalToSuperview().offset(min(0, -(scrollView.contentOffset.y + scrollView.contentInset.top)))
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            UIView.animate(withDuration: 0.5) {
                self.sexTypeButton.transform = CGAffineTransform(translationX: 50, y: 0)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            UIView.animate(withDuration: 0.5) {
                self.sexTypeButton.transform = CGAffineTransform.identity
            }
        }
    }
    
}
