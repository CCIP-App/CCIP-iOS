//
//  OPassAPI.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/3/7.
//  2019 OPass.
//

import Foundation
import Then
import AFNetworking
import SwiftyJSON
import UICKeyChainStore

class OPassAPI: NSObject {
    static var currentEvent: String = ""
    static var eventInfo: EventInfo? = nil
    static var userInfo: ScenarioStatus? = nil
    static var scenarios: [Scenario] = []
    static var isLoginSession: Bool = false
    static private var tabBarController: MainTabBarViewController? = nil

    static func InitializeRequest(_ url: String, maxRetry: UInt = 10, _ onceErrorCallback: OPassErrorCallback) -> Promise<Any?> {
        var retryCount: UInt = 0
        let e = Promise<Any?> { resolve, reject in
            let manager = AFHTTPSessionManager.init()
            manager.requestSerializer.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            manager.requestSerializer.timeoutInterval = 5
            manager.get(url, parameters: nil, headers: nil, progress: nil, success: { (_, responseObject: Any?) in
                #if DEBUG
                NSLog("JSON: \(JSONSerialization.stringify(responseObject as Any) ?? "nil")")
                #endif
                if (responseObject != nil) {
                    resolve(responseObject)
                }
            }) { (operation: URLSessionDataTask?, error: Error) in
                NSLog("Error: \(error)")
                 let err = error as NSError
                // let systemMsg = err.userInfo["NSLocalizedDescription"] ?? ""
                let response = operation?.response as? HTTPURLResponse
                let data = err.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? Data
                if let resp = response {
                    onceErrorCallback?(retryCount, maxRetry, error, response)
                    if let data = data {
                        resolve(OPassNonSuccessDataResponse(resp, data, JSON(data as Any)))
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                        retryCount += 1
                        onceErrorCallback?(retryCount, maxRetry, error, response)
                        reject(error)
                    })
                }
            }
        }
        if maxRetry > 0 {
            return e.retry(maxRetry)
        } else {
            return e
        }
    }

    static func initTabBar(_ tabVC: MainTabBarViewController) {
        tabBarController = tabVC
    }

    static func refreshTabBar() {
        guard let tabBarController = tabBarController else { return }
        guard let items = tabBarController.tabBar.items else { return }
        // setting selected image color from original image with replace custom color filter
        for item in items {
            guard let title = item.title else { return }
            guard let itemImage = item.image else { return }
            var image: UIImage = itemImage.withRenderingMode(.alwaysOriginal)
            image = image.imageWithColor(Constants.appConfigColor.HighlightedColor)
            item.selectedImage = image.withRenderingMode(.alwaysOriginal)
            switch title {
            case "Checkin", OPassAPI.eventInfo?.Features[OPassKnownFeatures.FastPass]?.DisplayText[Constants.shortLangUI]:
                item.title = OPassAPI.eventInfo?.Features[OPassKnownFeatures.FastPass]?.DisplayText[Constants.shortLangUI]
                item.isEnabled = OPassAPI.eventInfo?.Features[OPassKnownFeatures.FastPass]?.Url != nil
                if item.isEnabled && ((OPassAPI.userInfo?.Role ?? "").count > 0) {
                    if let role = OPassAPI.userInfo?.Role {
                        item.isEnabled = (OPassAPI.eventInfo?.Features[OPassKnownFeatures.FastPass]?.VisibleRoles?.contains(role)) ?? true
                    }
                }
                if !item.isEnabled {
                    tabBarController.viewControllers?.remove(at: 0)
                }
            case "Session", OPassAPI.eventInfo?.Features[OPassKnownFeatures.Schedule]?.DisplayText[Constants.shortLangUI]:
                item.title = OPassAPI.eventInfo?.Features[OPassKnownFeatures.Schedule]?.DisplayText[Constants.shortLangUI]
            case "Announce", OPassAPI.eventInfo?.Features[OPassKnownFeatures.Announcement]?.DisplayText[Constants.shortLangUI]:
                item.title = OPassAPI.eventInfo?.Features[OPassKnownFeatures.Announcement]?.DisplayText[Constants.shortLangUI]
                item.isEnabled = OPassAPI.eventInfo?.Features[OPassKnownFeatures.Announcement]?.Url != nil
            case "IRC", OPassAPI.eventInfo?.Features[OPassKnownFeatures.IM]?.DisplayText[Constants.shortLangUI]:
                item.title = OPassAPI.eventInfo?.Features[OPassKnownFeatures.IM]?.DisplayText[Constants.shortLangUI]
                item.isEnabled = OPassAPI.eventInfo?.Features[OPassKnownFeatures.IM]?.Url != nil
            default:
                item.title = NSLocalizedString(title, comment: "")
            }
        }
    }

    static func openFirstAvailableTab() {
        guard let tabBarController = tabBarController else { return }
        guard let items = tabBarController.tabBar.items else { return }
        for (index, item) in items.enumerated() {
            NSLog("\(index): \(String(describing: item.title)) -> \(item.isEnabled)")
            if item.isEnabled {
                tabBarController.selectedIndex = index
                break;
            }
        }
    }

    private static var LAST_EVENT_ID = "lastEventId";
    static var lastEventId: String {
        get {
            guard let lastId = UICKeyChainStore.string(forKey: LAST_EVENT_ID) else {
                UICKeyChainStore.setString("", forKey: LAST_EVENT_ID)
                return ""
            }
            return lastId
        }
        set {
            UICKeyChainStore.setString(newValue, forKey: LAST_EVENT_ID)
        }
    }
}
