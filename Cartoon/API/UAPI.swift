//
//  UAPI.swift
//  Cartoon
//
//  Created by apple on 2018/11/1.
//  Copyright © 2018年 hzbojin. All rights reserved.
//

import Moya
import HandyJSON
import MBProgressHUD

//MARK:请求方法
enum UApi {
    case searchHot//搜索热门
    case searchRelative(inputText: String)//相关搜索
    case searchResult(argCon: Int, q: String)//搜索结果
    
    case boutiqueList(sexType: Int)//推荐列表
    case special(argCon: Int, page: Int)//专题
    case vipList//VIP列表
    case subscribeList//订阅列表
    case rankList//排行列表
    
    case cateList//分类列表
    
    case comicList(argCon: Int, argName: String, argValue: Int, page: Int)//漫画列表
    
    case guessLike//猜你喜欢
    
    case detailStatic(comicid: Int)//详情(基本)
    case detailRealtime(comicid: Int)//详情(实时)
    case commentList(object_id: Int, thread_id: Int, page: Int)//评论
    
    case chapter(chapter_id: Int)//章节内容                      //排行列表
}

//MARK: 参数设置
extension UApi: TargetType {
    private struct UApiKey {
        static var key = "fabe6953ce6a1b8738bd2cabebf893a472d2b6274ef7ef6f6a5dc7171e5cafb14933ae65c70bceb97e0e9d47af6324d50394ba70c1bb462e0ed18b88b26095a82be87bc9eddf8e548a2a3859274b25bd0ecfce13e81f8317cfafa822d8ee486fe2c43e7acd93e9f19fdae5c628266dc4762060f6026c5ca83e865844fc6beea59822ed4a70f5288c25edb1367700ebf5c78a27f5cce53036f1dac4a776588cd890cd54f9e5a7adcaeec340c7a69cd986:::open"
    }

    var baseURL: URL { return URL(string: "http://app.u17.com/v3/appV3_3/ios/phone")! }

    var headers: [String : String]? { return nil }

    var method: Moya.Method { return .get }
    
    var sampleData: Data { return "".data(using: String.Encoding.utf8)! }

    var path: String {
        switch self {
        case .searchHot: return "search/hotkeywordsnew"
        case .searchRelative: return "search/relative"
        case .searchResult: return "search/searchResult"

        case .boutiqueList: return "comic/boutiqueListNew"
        case .special: return "comic/special"
        case .vipList: return "list/vipList"
        case .subscribeList: return "list/newSubscribeList"
        case .rankList: return "rank/list"

        case .cateList: return "sort/mobileCateList"

        case .comicList: return "list/commonComicList"

        case .guessLike: return "comic/guessLike"

        case .detailStatic: return "comic/detail_static_new"
        case .detailRealtime: return "comic/detail_realtime"
        case .commentList: return "comment/list"

        case .chapter: return "comic/chapterNew"
        }
    }

    var task: Task {
        var parmeters = ["time": Int32(Date().timeIntervalSince1970),
                         "device_id": UIDevice.current.identifierForVendor!.uuidString,
                         "key": UApiKey.key,
                         "model": UIDevice.current.modelName,
                         "target": "U17_3.0",
                         "version": Bundle.main.infoDictionary!["CFBundleShortVersionString"]!]
        
        switch self {
        case let .searchRelative(inputText):
            parmeters["inputText"] = inputText
            
        case let .searchResult(argCon, q):
            parmeters["argCon"] = argCon
            parmeters["q"] = q
            
        case let .boutiqueList(sexType):
            parmeters["sexType"] = sexType
            parmeters["v"] = 3320101
            
        case let .special(argCon, page):
            parmeters["argCon"] = argCon
            parmeters["page"] = max(1, page)
            
        case .cateList:
            parmeters["v"] = 2
            
        case let .comicList( argCon, argName, argValue, page):
            parmeters["argCon"] = argCon
            if argName.count > 0 { parmeters["argName"] = argName }
            parmeters["argValue"] = argValue
            parmeters["page"] = max(1, page)
            
        case let .detailStatic(comicid),
             let .detailRealtime(comicid):
            parmeters["comicid"] = comicid
            parmeters["v"] = 3320101
            
        case let .commentList(object_id, thread_id, page):
            parmeters["object_id"] = object_id
            parmeters["thread_id"] = thread_id
            parmeters["page"] = page
            
        case let .chapter(chapter_id):
            parmeters["chapter_id"] = chapter_id
            
        default: break
        }
        
        return .requestParameters(parameters: parmeters, encoding: URLEncoding.default)
    }
}


let LoadingPlugin = NetworkActivityPlugin { (type, target)  in
    guard let vc = topVC else { return }
    switch type {
    case .began:
        MBProgressHUD.hide(for: vc.view, animated: false)
        MBProgressHUD.showAdded(to: vc.view, animated: true)
    case .ended:
        MBProgressHUD.hide(for: vc.view, animated: true)
    }
}

let timeoutClosure = {(endpoint: Endpoint, closure: MoyaProvider<UApi>.RequestResultClosure) -> Void in
    if var urlRequest = try? endpoint.urlRequest() {  //urlRequest()为throwing函数,所以需要用try?处理错误
        urlRequest.timeoutInterval = 10
        closure(.success(urlRequest))
    } else {
        closure(.failure(MoyaError.requestMapping(endpoint.url)))
    }
}

let ApiProvider = MoyaProvider<UApi>()
let ApiLoadingProvider = MoyaProvider<UApi>(requestClosure: timeoutClosure, plugins: [LoadingPlugin])


extension Response {
    func mapModel<T: HandyJSON>(_ type: T.Type) throws -> T {
        let jsonString = String(data: data, encoding: .utf8)
        //json转model
        guard let model = JSONDeserializer<T>.deserializeFrom(json: jsonString) else {
            throw MoyaError.jsonMapping(self)
        }
        return model
    }
}

extension MoyaProvider {
    @discardableResult
    func request<T: HandyJSON>(_ target: Target,
                               model: T.Type,
                               completion: ((_ returnData: T?) -> Void)?) -> Cancellable? {
        return request(target, completion: { (result) in
            //若无闭包则不继续执行
            guard let completion = completion else { return }
            //将数据转为model,因为调用mapModel方法会抛出错误,所以在调用方法前面加try关键字
            guard let returnData = try? result.value?.mapModel(ResponseData<T>.self) else {
                completion(nil)
                return
            }
            completion(returnData?.data?.returnData)
        })
    }
}
