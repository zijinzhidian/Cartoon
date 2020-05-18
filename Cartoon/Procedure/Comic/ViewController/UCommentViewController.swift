//
//  UCommentViewController.swift
//  Cartoon
//
//  Created by apple on 2018/12/25.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

private let kCommentTCellID = "commentTCellID"

class UCommentViewController: UBaseViewController {
    
    weak var delegate: UComicViewWillEndDraggingDelegate?
    
    var detailStatic: DetailStaticModel?
    var commentList: CommentListModel? {
        didSet {
            guard let commentList = commentList?.commentList else { return }
            let viewModelArray = commentList.compactMap { (comment) -> UCommentViewModel in
                return UCommentViewModel(model: comment)
            }
            listArray.append(contentsOf: viewModelArray)
        }
    }
    
    private var listArray = [UCommentViewModel]()
    
    private lazy var tableView: UITableView = {
        let tw = UITableView(frame: .zero, style: .plain)
        tw.delegate = self
        tw.dataSource = self
        tw.uFoot = URefreshFooter { self.loadData() }
        tw.register(UCommentTCell.self, forCellReuseIdentifier: kCommentTCellID)
        return tw
    }()
    
    private func loadData() {
        ApiProvider.request(UApi.commentList(object_id: detailStatic?.comic?.comic_id ?? 0,
                                             thread_id: detailStatic?.comic?.thread_id ?? 0,
                                             page: commentList?.serverNextPage ?? 0),
                            model: CommentListModel.self) { (returnData) in
                                if returnData?.hasMore == true {
                                    self.tableView.uFoot?.endRefreshing()
                                } else {
                                    self.tableView.uFoot?.endRefreshingWithNoMoreData()
                                }
                                self.commentList = returnData
                                self.tableView.reloadData()
        }
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    override func configUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

extension UCommentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCommentTCellID, for: indexPath) as! UCommentTCell
        cell.viewModel = listArray[indexPath.row]
        return cell
    }
}

extension UCommentViewController: UITableViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.comicWillEndDragging(scrollView)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return listArray[indexPath.row].height
    }
}
