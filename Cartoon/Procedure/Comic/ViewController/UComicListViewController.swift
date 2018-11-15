//
//  UComicListViewController.swift
//  Cartoon
//
//  Created by apple on 2018/11/6.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

private let kComicTCell = "comicTCellID"

class UComicListViewController: UBaseViewController {
    private var argCon: Int = 0
    private var argName: String?
    private var argValue: Int = 0
    private var page: Int = 1
    
    private var comicList = [ComicModel]()
    private var spinerName: String?
    
    private lazy var tableView: UITableView = {
        let tw = UITableView(frame: CGRect.zero, style: .plain)
        tw.backgroundColor = UIColor.background
        tw.tableFooterView = UIView()
        tw.delegate = self
        tw.dataSource = self
        tw.register(UComicTCell.self, forCellReuseIdentifier: kComicTCell)
        tw.uHead = URefreshHeader { [weak self] in self?.loadData(more: false) }
        tw.uFoot = URefreshFooter { [weak self] in self?.loadData(more: true) }
        tw.uEmpty = UEmptyView { [weak self] in self?.loadData(more: false) }
        return tw
    }()
    
    convenience init(argCon: Int = 0, argName: String?, argValue: Int = 0) {
        self.init()
        self.argCon = argCon
        self.argName = argName
        self.argValue = argValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData(more: false)
    }
    
    @objc private func loadData(more: Bool) {
        page = (more ? page + 1 : 1)
        ApiLoadingProvider.request(UApi.comicList(argCon: argCon, argName: argName ?? "", argValue: argValue, page: page),
                                   model: ComicListModel.self) { [weak self] (resultData) in
                                    
                                    self?.tableView.uHead.endRefreshing()
                                    if resultData?.hasMore == false {
                                        self?.tableView.uFoot.endRefreshingWithNoMoreData()
                                    } else {
                                        self?.tableView.uFoot.endRefreshing()
                                    }
                                    self?.tableView.uEmpty?.allowShow = true
                                    
                                    if !more { self?.comicList.removeAll() }
                                    
                                    self?.comicList.append(contentsOf: resultData?.comics ?? [])
                                    self?.tableView.reloadData()
                                    
                                    guard let defaultParameters = resultData?.defaultParameters else { return }
                                    self?.argCon = defaultParameters.defaultArgCon
                                    self?.spinerName = defaultParameters.defaultConTagType
                                    
        }                           
    }
    
    override func configUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}


extension UComicListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comicList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kComicTCell, for: indexPath) as! UComicTCell
        cell.spinnerName = spinerName
        cell.indexPath = indexPath
        cell.model = comicList[indexPath.row]
        return cell
    }
}

extension UComicListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
}
