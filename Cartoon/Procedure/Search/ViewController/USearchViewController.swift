//
//  USearchViewController.swift
//  有妖气漫画
//
//  Created by apple on 2018/10/31.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import UIKit
import Moya
import HandyJSON

private let kHistoryTCellID = "historyTCellID"
private let kSearchTCellID = "searchTCellID"
private let kResultTCellID = "resultTCellID"

private let kHistoryTHeadID = "historyTHeadID"
private let kHistoryTFootID = "historyTFootID"
private let kSearchTHeadID = "searchTHeadID"

class USearchViewController: UBaseViewController {
    
    private var currentRequest: Cancellable?
    
    private var hotItems: [SearchItemModel]?
    
    private var relative: [SearchItemModel]?
    
    private var comics: [ComicModel]?
    
    private lazy var searchHistory: [String] = {
        return UserDefaults.standard.value(forKey: String.searchHistoryKey) as? [String] ?? [String]()
    }()
    
    private lazy var searchBar: UITextField = {
        let sr = UITextField()
        sr.backgroundColor = UIColor.white
        sr.textColor = UIColor.gray
        sr.tintColor = UIColor.darkGray
        sr.font = UIFont.systemFont(ofSize: 15)
        sr.placeholder = "输入漫画名称/作者"
        sr.layer.cornerRadius = 15
        sr.clearsOnBeginEditing = true
        sr.returnKeyType = .search
        sr.clearButtonMode = .whileEditing
        sr.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        sr.leftViewMode = .always
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChanged(noti:)), name: UITextField.textDidChangeNotification, object: sr)
        return sr
    }()
    
    private lazy var historyTableView: UITableView = {
        let hw = UITableView(frame: CGRect.zero, style: .grouped)
        hw.dataSource = self
        hw.delegate = self
        hw.register(USearchTHead.self, forHeaderFooterViewReuseIdentifier: kHistoryTHeadID)
        hw.register(UBaseTableViewCell.self, forCellReuseIdentifier: kHistoryTCellID)
        hw.register(USearchTFoot.self, forHeaderFooterViewReuseIdentifier: kHistoryTFootID)
        return hw
    }()
    
    private lazy var searchTableView: UITableView = {
        let sw = UITableView(frame: CGRect.zero, style: .plain)
        sw.tableFooterView = UIView()
        sw.dataSource = self
        sw.delegate = self
        sw.register(USearchTHead.self, forHeaderFooterViewReuseIdentifier: kSearchTHeadID)
        sw.register(UBaseTableViewCell.self, forCellReuseIdentifier: kSearchTCellID)
        return sw
    }()
    
    private lazy var resultTableView: UITableView = {
        let rw = UITableView(frame: CGRect.zero, style: .plain)
        rw.tableFooterView = UIView()
        rw.dataSource = self
        rw.delegate = self
        rw.register(UComicTCell.self, forCellReuseIdentifier: kResultTCellID)
        return rw
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadHistory()
    }
    
    override func configUI() {
        view.addSubview(historyTableView)
        historyTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(searchTableView)
        searchTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(resultTableView)
        resultTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func configNavigationBar() {
        super.configNavigationBar()
        searchBar.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 30)
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelAction))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    }
    
    @objc private func cancelAction() {
        navigationController?.popViewController(animated: true)
    }
    
    private func loadHistory() {
        historyTableView.isHidden = false
        searchTableView.isHidden = true
        resultTableView.isHidden = true
        ApiLoadingProvider.request(UApi.searchHot, model: HotItemsModel.self) { (returnData) in
            self.hotItems = returnData?.hotItems
            self.historyTableView.reloadData()
        }
    }
    
    private func searchRelative(_ text: String) {
        if text.count > 0 {
            historyTableView.isHidden = true
            searchTableView.isHidden = false
            resultTableView.isHidden = true
            currentRequest?.cancel()
            print(text)
            currentRequest = ApiProvider.request(UApi.searchRelative(inputText: text), model: [SearchItemModel].self) { (returnData) in
                self.relative = returnData
                self.searchTableView.reloadData()
            }
        } else {
            historyTableView.isHidden = false
            searchTableView.isHidden = true
            resultTableView.isHidden = true
        }
    }
    
    private func searchResult(_ text: String) {
        if text.count > 0 {
            historyTableView.isHidden = true
            searchTableView.isHidden = true
            resultTableView.isHidden = false
            searchBar.text = text
            ApiLoadingProvider.request(UApi.searchResult(argCon: 0, q: text), model: SearchResultModel.self) { (returnData) in
                self.comics = returnData?.comics
                self.resultTableView.reloadData()
            }
            
            let defaults = UserDefaults.standard
            var history = defaults.value(forKey: String.searchHistoryKey) as? [String] ?? [String]()
            history.removeAll([text])
            history.insert(text, at: 0)
            
            searchHistory = history
            historyTableView.reloadData()
            
            defaults.set(searchHistory, forKey: String.searchHistoryKey)
            defaults.synchronize()
            
        } else {
            historyTableView.isHidden = false
            searchTableView.isHidden = true
            resultTableView.isHidden = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension USearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == historyTableView {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == historyTableView {
            return section == 0 ? searchHistory.count : 0
        } else if tableView == searchTableView {
            return relative?.count ?? 0
        } else {
            return comics?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == historyTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: kHistoryTCellID, for: indexPath) as! UBaseTableViewCell
            cell.textLabel?.text = searchHistory[indexPath.row]
            cell.textLabel?.textColor = UIColor.darkGray
            cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
            cell.separatorInset = .zero
            return cell
        } else if tableView == searchTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: kSearchTCellID, for: indexPath) as! UBaseTableViewCell
            cell.textLabel?.text = relative?[indexPath.row].name
            cell.textLabel?.textColor = UIColor.darkGray
            cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
            cell.separatorInset = .zero
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: kResultTCellID, for: indexPath) as! UComicTCell
            cell.model = comics?[indexPath.row]
            return cell
        }
    }
}

extension USearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == historyTableView {
            searchResult(searchHistory[indexPath.row])
        } else if tableView == searchTableView {
            searchResult(relative?[indexPath.row].name ?? "")
        } else if tableView == resultTableView {
            guard let model = comics?[indexPath.row] else { return }
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == historyTableView {
            let head = tableView.dequeueReusableHeaderFooterView(withIdentifier: kHistoryTHeadID) as! USearchTHead
            head.titleLabel.text = section == 0 ? "看看你都搜过什么" : "大家都在搜"
            head.moreButton.setImage(section == 0 ? UIImage(named: "search_history_delete") : UIImage(named: "search_keyword_refresh"), for: .normal)
            head.moreButton.isHidden = section == 0 ? (searchHistory.count == 0) : false
            head.moreActionClosure = { [weak self] in
                if section == 0 {
                    self?.searchHistory.removeAll()
                    self?.historyTableView.reloadData()
                    UserDefaults.standard.removeObject(forKey: String.searchHistoryKey)
                    UserDefaults.standard.synchronize()
                } else {
                    self?.loadHistory()
                }
            }
            return head
        } else if tableView == searchTableView {
            let head = tableView.dequeueReusableHeaderFooterView(withIdentifier: kSearchTHeadID) as! USearchTHead
            head.titleLabel.text = "找到相关的动画\(comics?.count ?? 0)本"
            head.moreButton.isHidden = true
            return head
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == historyTableView && section == 1 {
            let foot = tableView.dequeueReusableHeaderFooterView(withIdentifier: kHistoryTFootID) as! USearchTFoot
            foot.data = hotItems ?? []
            foot.didSelecteIndexClosure = { [weak self] (index, model) in
                let vc = UComicViewController(comicid: model.comic_id)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            return foot
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == resultTableView {
            return 180
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == historyTableView {
            return 44
        } else if tableView == searchTableView {
            return comics?.count ?? 0 > 0 ? 44 : CGFloat.leastNormalMagnitude
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == historyTableView {
            return section == 0 ? 10 : tableView.frame.height - 44
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }

}


extension USearchViewController: UITextFieldDelegate {
    @objc func textFieldTextDidChanged(noti: Notification) {
        guard let textField = noti.object as? UITextField,
            let text = textField.text else { return }
        searchRelative(text)
    }
}
