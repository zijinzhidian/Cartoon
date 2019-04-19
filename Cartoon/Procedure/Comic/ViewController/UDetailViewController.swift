//
//  UDetailViewController.swift
//  Cartoon
//
//  Created by apple on 2018/12/24.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

private let kDescriptionTCellID = "descriptionTCellID"
private let kOtherWorksTCell = "otherWorksTCell"
private let kTicketTCell = "ticketTCell"
private let kGuessLikeTCell = "guessLikeTCell"

class UDetailViewController: UBaseViewController {
    
    weak var delegate: UComicViewWillEndDraggingDelegate?
    
    var detailStatic: DetailStaticModel?
    var detailRealtime: DetailRealtimeModel?
    var guessLike: GuessLikeModel?
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = UIColor.background
        tv.separatorStyle = .none
        tv.delegate = self
        tv.dataSource = self
        tv.register(UDescriptionTCell.self, forCellReuseIdentifier: kDescriptionTCellID)
        tv.register(UOtherWorksTCell.self, forCellReuseIdentifier: kOtherWorksTCell)
        tv.register(UTicketTCell.self, forCellReuseIdentifier: kTicketTCell)
        tv.register(UGuessLikeTCell.self, forCellReuseIdentifier: kGuessLikeTCell)
        return tv
    }()
    
    func reloadData() {
        tableView.reloadData()
    }
    
    override func configUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}


extension UDetailViewController: UITableViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.comicWillEndDragging(scrollView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let vc = UOtherWorksViewController(otherWorks: detailStatic?.otherWorks)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UDescriptionTCell.height(for: detailStatic)
        } else if indexPath.section == 3 {
            return 200
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (section == 1 && detailStatic?.otherWorks?.count == 0) ? CGFloat.leastNormalMagnitude : 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}


extension UDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return detailStatic != nil ? 4 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 1 && detailStatic?.otherWorks?.count == 0) ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: kDescriptionTCellID, for: indexPath) as! UDescriptionTCell
            cell.model = detailStatic
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: kOtherWorksTCell, for: indexPath) as! UOtherWorksTCell
            cell.model = detailStatic
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: kTicketTCell, for: indexPath) as! UTicketTCell
            cell.model = detailRealtime
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: kGuessLikeTCell, for: indexPath) as! UGuessLikeTCell
            cell.model = guessLike
            cell.didSelectClosure = { [weak self] comic in
                let vc = UComicViewController(comicid: comic.comic_id)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
        }
        
    }
}
