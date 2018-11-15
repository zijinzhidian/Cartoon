//
//  USpecialViewController.swift
//  Cartoon
//
//  Created by apple on 2018/11/7.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit

private let kSpecialTCellID = "specialTCellID"

class USpecialViewController: UBaseViewController {
    
    private var page: Int = 1
    private var argCon: Int = 0
    
    private var specialList = [ComicModel]()
    
    private lazy var tableView: UITableView = {
        let tw = UITableView(frame: CGRect.zero, style: .plain)
        tw.backgroundColor = UIColor.background
        tw.tableFooterView = UIView()
        tw.delegate = self
        tw.dataSource = self
        tw.separatorStyle = .none
        tw.register(USpecialTCell.self, forCellReuseIdentifier: kSpecialTCellID)
        tw.uHead = URefreshHeader { [weak self] in self?.loadData(more: false) }
        tw.uFoot = URefreshFooter { [weak self] in self?.loadData(more: true) }
        tw.uEmpty = UEmptyView { [weak self] in self?.loadData(more: false) }
        return tw
    }()
    
    convenience init(argCon: Int = 0) {
        self.init()
        self.argCon = argCon
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData(more: false)
    }
    
    @objc private func loadData(more: Bool) {
        page = more ? page + 1 : 1
        ApiLoadingProvider.request(UApi.special(argCon: argCon, page: page), model: ComicListModel.self) { [weak self] (returnData) in
            
            self?.tableView.uHead.endRefreshing()
            if returnData?.hasMore == false {
                self?.tableView.uFoot.endRefreshingWithNoMoreData()
            } else {
                self?.tableView.uFoot.endRefreshing()
            }
            self?.tableView.uEmpty?.allowShow = true
            
            if !more { self?.specialList.removeAll() }
            self?.specialList.append(contentsOf: returnData?.comics ?? [])
            self?.tableView.reloadData()
            
            guard let defaultParameters = returnData?.defaultParameters else { return }
            self?.argCon = defaultParameters.defaultArgCon
        }
    }
    
    override func configUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}


extension USpecialViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return specialList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kSpecialTCellID, for: indexPath) as! USpecialTCell
        cell.model = specialList[indexPath.row]
        return cell
    }
}


extension USpecialViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = specialList[indexPath.row]
        var html: String?
        if item.specialType == 1 {
            html = "http://www.u17.com/z/zt/appspecial/special_comic_list_v3.html"
        } else if item.specialType == 2 {
            html = "http://www.u17.com/z/zt/appspecial/special_comic_list_new.html"
        }
        guard let host = html else { return }
        let path = "special_id=\(item.specialId)&is_comment=\(item.isComment)"
        let url = [host, path].joined(separator: "?")
        let vc = UBaseWebViewController(url: url)
        navigationController?.pushViewController(vc, animated: true)
    }
}
