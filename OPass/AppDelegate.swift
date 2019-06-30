//
//  AppDelegate.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/22.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import NetworkExtension
import UserNotifications
import OneSignal
import Firebase
import UICKeyChainStore
import ScanditBarcodeScanner
import Appirater
import iVersion
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, UIViewControllerPreviewingDelegate {
    var window: UIWindow?
    public var checkinView: CheckinViewController?
    public var userInfo: ScenarioStatus?
    public var beacon = iBeacon.init()
    public var appArt: SLColorArt {
        get {
            struct aa {
                static var appArt: SLColorArt?
                static var appIconName: String = ""

            }
            if aa.appArt != nil {
                return aa.appArt!
            } else {
                // find the biggest icon for AppArt
                // and find biggest app icon file name
                let bundle = Bundle.main.infoDictionary!
                let bundleIcons = (bundle as NSDictionary).value(forKeyPath: "CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles") as! Array<String>
                guard let bundleFiles = try? FileManager.init().contentsOfDirectory(atPath: Bundle.main.resourcePath!) else { return SLColorArt.init() }
                var availIcon = Array<String>()
                for iconPrefix in bundleIcons {
                    for file in bundleFiles {
                        if file.range(of: iconPrefix, options: .caseInsensitive, range: nil, locale: nil) != nil {
                            availIcon += [ file ]
                        }
                    }
                }
                // find the biggest image metrix
                var sizeMetrix = 0
                var fileName = ""
                for iconName in availIcon {
                    guard let regex = try? NSRegularExpression.init(pattern: "([\\d]+).([\\d]+)(@([\\d]+)x)?", options: .caseInsensitive) else { return SLColorArt.init() }
                    regex.enumerateMatches(in: iconName, options: .reportCompletion, range: NSRange.init(location: 0, length: iconName.count)) { (match, flags, stop) in
                        if !flags.contains([ .completed, .hitEnd ]) {
                            let wRange = match!.range(at: 1)
                            let width = Int(iconName[wRange])!
                            let hRange = match!.range(at: 2)
                            let height = Int(iconName[hRange])!
                            var mutiple = 1
                            let mpRange = match!.range(at: 4)
                            if mpRange.location != NSNotFound {
                                mutiple = Int(iconName[mpRange])!
                                let size = width * height * mutiple
                                if size > sizeMetrix {
                                    sizeMetrix = size
                                    fileName = iconName
                                }
                            }
                        }
                    }
                    aa.appIconName = (fileName as NSString).deletingPathExtension
                    aa.appArt = UIImage.init(named: aa.appIconName)?.colorArt()
                }
                self.setAppearance(aa.appArt!)
                return aa.appArt!
            }
        }
    }

    static var delegateInstance: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    static func sendTag(_ tag: String, value: String) {
        OneSignal.sendTag(tag, value: value)
    }

    static func sendTags(_ keyValuePair: [AnyHashable: Any]) {
        OneSignal.sendTags(keyValuePair)
    }

    static func sendTagsWithJsonString(_ jsonString: String) {
        OneSignal.sendTags(withJsonString: jsonString)
    }

    func setAppearance(_ appArt: SLColorArt) {
        //[[UINavigationBar appearance] setBarTintColor:[appArt backgroundColor]];
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = .white
        UIBarButtonItem.appearance().tintColor = .white
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationController.self]).tintColor = Constants.appConfigColor("NavigationIndicatorColor")

        let imagePickerNavBarAppearance = UINavigationBar.appearance(whenContainedInInstancesOf: [UIImagePickerController.self])
        imagePickerNavBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        imagePickerNavBarAppearance.tintColor = Constants.tintColor
        let imagePickerBarButtonItemAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIImagePickerController.self])
        imagePickerBarButtonItemAppearance.tintColor = Constants.tintColor
        let imagePickerButtonAppearance = UIButton.appearance(whenContainedInInstancesOf: [UIImagePickerController.self])
        imagePickerButtonAppearance.tintColor = Constants.tintColor

        UIToolbar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).barTintColor = appArt.backgroundColor

        let labelTextColor = Constants.appConfigColor("LabelTextColor")
        UITabBar.appearance().tintColor = labelTextColor
        UISegmentedControl.appearance().tintColor = labelTextColor
        UIProgressView.appearance().tintColor = labelTextColor
        UILabel.appearance().tintColor = labelTextColor
        UISearchBar.appearance().tintColor = labelTextColor
    }

    func displayGreetingsForLogin() {
        OPassAPI.isLoginSession = false
        let ac = UIAlertController.alertOfTitle("", withMessage: String.init(format: NSLocalizedString("LoginGreeting", comment: ""), self.userInfo?.UserId ?? ""), cancelButtonText: NSLocalizedString("Okay", comment: ""), cancelStyle: .destructive, cancelAction: nil)
        ac.showAlert {
            UIImpactFeedback.triggerFeedback(.notificationFeedbackSuccess)
        }
    }

    func parseUniversalLinkAndURL(_ isOldScheme: Bool, _ link: String) -> Bool {
        return self.parseUniversalLinkAndURL(isOldScheme, URL.init(string: link)!)
    }

    func parseUniversalLinkAndURL(_ isOldScheme: Bool, _ url: URL) -> Bool {
        NSLog("Calling from: \(url)")
        let params = URLComponents(string: url.query ?? "")?.queryItems
        let event_id = params?.first(where: { $0.name == "event_id" })?.value
        let token = params?.first(where: { $0.name == "token" })?.value
        if isOldScheme {
            let ac = UIAlertController.alertOfTitle(NSLocalizedString("GuideViewTokenErrorTitle", comment: ""), withMessage: NSLocalizedString("GuideViewTokenErrorDesc", comment: ""), cancelButtonText: NSLocalizedString("GotIt", comment: ""), cancelStyle: .cancel, cancelAction: nil)
            if event_id != nil && token != nil {
                OPassAPI.DoLogin(event_id!, token!) { success, data, error in
                    if !success && data != nil {
                        ac.showAlert {
                            UIImpactFeedback.triggerFeedback(.notificationFeedbackError)
                        }
                    }
                }
                return true
            }
            if event_id == nil && token != nil && Constants.HasSetEvent {
                OPassAPI.RedeemCode("", token!) { success, data, error in
                    if !success && data != nil {
                        ac.showAlert {
                            UIImpactFeedback.triggerFeedback(.notificationFeedbackError)
                        }
                    }
                }
            }
            return true
        }
        Constants.OpenInAppSafari(forURL: url)
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let dynamicLink = DynamicLinks.init().dynamicLink(fromCustomSchemeURL: url)
        if dynamicLink != nil {
            if dynamicLink!.url != nil {
                return self.parseUniversalLinkAndURL(true, dynamicLink!.url!)
            }
        } else {
            return self.parseUniversalLinkAndURL(true, url)
        }
        return false
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))! {
            // User did tap at remote notification
        }
        completionHandler()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.setDefaultShortcutItems()
        NSLog("Receieved remote system fetching request...\nuserInfo => \(userInfo)")
        completionHandler(.newData)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        // Override point for customization after application launch.
        OPassAPI.isLoginSession = false
        // Configure tracker from GoogleService-Info.plist.
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = (Bundle.main.infoDictionary! as NSObject).valueForKeyPathWithIndexes("CFBundleURLTypes[0].CFBundleURLSchemes[0]") as? String
        FirebaseApp.configure()

        //    //configure iRate
        //    [iRate sharedInstance].daysUntilPrompt = 1;
        //    [iRate sharedInstance].usesUntilPrompt = 5;
        //    //enable preview mode
        //    [iRate sharedInstance].previewMode = NO;

        //configure iVersion
        //set custom BundleID
        iVersion.sharedInstance()?.applicationBundleID = Bundle.main.bundleIdentifier
        //enable preview mode
        iVersion.sharedInstance()?.previewMode = false

        let uTrackId = iVersion.sharedInstance()?.appStoreID
        NSLog(iVersion.sharedInstance().appStoreCountry)

        // Configure Appirater
        let trackId = uTrackId != nil ? "\(uTrackId!)" : ""
        if trackId.count > 0 {
            Appirater.setAppId(trackId)
            Appirater.setDaysUntilPrompt(1)
            Appirater.setUsesUntilPrompt(5)
            Appirater.setSignificantEventsUntilPrompt(-1)
            Appirater.setTimeBeforeReminding(1)
            Appirater.setDebug(false)
            Appirater.appLaunched(true)
        }

        // Configure OneSignal
        let oneSignalToken = Constants.appConfig("ogToken") as! String

        func notificationReceiverBlock(_ notification: OSNotification) {
            NSLog("Received Notification - \(notification.payload.notificationID ?? "")")
        }
        func notificationOpenedBlock(_ result: OSNotificationOpenedResult) {
            // This block gets called when the user reacts to a notification received
            let payload = result.notification.payload

            var messageTitle = "OneSignal Message"
            var fullMessage = payload?.body.copy() as! String

            if payload?.additionalData != nil {
                if payload?.title != nil {
                    messageTitle = payload!.title
                }

                let additionData = payload?.additionalData as! Dictionary<String, String>

                if (additionData["actionSelected"] != nil) {
                    fullMessage = "\(fullMessage)\nPressed ButtonId:\(additionData["actionSelected"]!)"
                }
            }
            NSLog("OneSignal Notification \(messageTitle): \(fullMessage)")
            //        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:messageTitle
            //                                                            message:fullMessage
            //                                                           delegate:self
            //                                                  cancelButtonTitle:@"Close"
            //                                                  otherButtonTitles:nil, nil];
            //        [alertView show];
        }

        let onesignalInitSettings = [
            kOSSettingsKeyAutoPrompt: false
        ]
        OneSignal.initWithLaunchOptions(launchOptions, appId: oneSignalToken, handleNotificationReceived: notificationReceiverBlock as? OSHandleNotificationReceivedBlock, handleNotificationAction: notificationOpenedBlock as? OSHandleNotificationActionBlock, settings: onesignalInitSettings)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })

        Constants.accessToken = UICKeyChainStore.string(forKey: "token") ?? ""
        NSLog("User Token: <\(Constants.accessToken ?? "n/a")>")

        // Provide the app key for your scandit license.
        SBSLicense.setAppKey(Constants.appConfig("scandit") as! String)

        self.setAppearance(self.appArt)
        self.setDefaultShortcutItems()

        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.webpageURL != nil {
        NSLog("Receieved Activity URL -> \(userActivity.webpageURL!)");
            var handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { dynamicLink, error in
                if dynamicLink?.url != nil {
                    let _ = self.parseUniversalLinkAndURL(false, dynamicLink!.url!)
                }
            }
            if !handled {
                // non Firbase Dynamic Link
                handled = self.parseUniversalLinkAndURL(false, userActivity.webpageURL!)
            }
            return handled
        }
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        self.setDefaultShortcutItems()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let userDefault = UserDefaults.standard
        userDefault.register(defaults: [
            Constants.SESSION_CACHE_CLEAR: false,
            Constants.SESSION_CACHE_KEY: [:]
        ])
        userDefault.synchronize()
        if userDefault.bool(forKey: Constants.SESSION_CACHE_CLEAR) {
            userDefault.set(false, forKey: Constants.SESSION_CACHE_CLEAR)
            userDefault.set([:], forKey: Constants.SESSION_CACHE_KEY)
            userDefault.synchronize()
        }

        guard let presentedView = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController else { return }
        if Constants.haveAccessToken && presentedView.className == GuideViewController.className {
            let guideVC = presentedView as! GuideViewController
            guideVC.redeemCodeText.text = Constants.accessToken
            let delayMSec = TimeInterval.init(750)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayMSec) {
                // TODO: refresh card data
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        // shortcutItem.type
        // shortcutItem.localizedTitle
        // shortcutItem.localizedSubtitle
        // shortcutItem.userInfo (NSDictionary*)
        let userDefault = UserDefaults.standard

        var mainTabBarViewIndex = 0
        if shortcutItem.type == "Checkin" {
            mainTabBarViewIndex = 0
            // TODO: switch to currect card
            userDefault.set(shortcutItem.userInfo, forKey: "CheckinCard")
        } else if shortcutItem.type == "Session" {
            mainTabBarViewIndex = 1
            userDefault.set(shortcutItem.localizedTitle, forKey: "SessionIndexText")
            userDefault.set(shortcutItem.userInfo, forKey: "SessionData")
        }
        userDefault.set(mainTabBarViewIndex, forKey: "MainTabBarViewIndex")

        // Save UserDefaults
        userDefault.synchronize()

        Constants.SendFib("performActionForShortcutItem", WithEvents: ["Title": shortcutItem.localizedTitle])
    }

    func setDefaultShortcutItems() {
        UIApplication.shared.shortcutItems = []
        //    static NSDateFormatter *formatter_full = nil;
        //    if (formatter_full == nil) {
        //        formatter_full = [NSDateFormatter new];
        //        [formatter_full setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        //        [formatter_full setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        //    }
        //
        //    static NSDateFormatter *formatter_date = nil;
        //    if (formatter_date == nil) {
        //        formatter_date = [NSDateFormatter new];
        //        [formatter_date setDateFormat:@"MM/dd"];
        //    }
        //    static NSDate *startTime;
        //    static NSString *time_date;
        //
        //    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        //    [manager GET:CC_STATUS([AppDelegate accessToken]) parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //        NSLog(@"JSON: %@", responseObject);
        //        if (responseObject != nil) {
        //            NSDictionary *scenarios = [responseObject objectForKey:@"scenarios"];
        //            [manager GET:PROGRAM_DATA_URL parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //                NSLog(@"JSON: %@", responseObject);
        //                if (responseObject != nil) {
        //                    NSArray *programs = responseObject;
        //
        //                    NSMutableDictionary *datesDict = [NSMutableDictionary new];
        //                    for (NSDictionary *program in programs) {
        //                        startTime = [formatter_full dateFromString:[program objectForKey:@"starttime"]];
        //                        time_date = [formatter_date stringFromDate:startTime];
        //
        //                        NSMutableArray *tempArray = [datesDict objectForKey:time_date];
        //                        if (tempArray == nil) {
        //                            tempArray = [NSMutableArray new];
        //                        }
        //                        [tempArray addObject:program];
        //                        [datesDict setObject:tempArray forKey:time_date];
        //                    }
        //
        //                    NSMutableDictionary *program_date = datesDict;
        //                    NSArray *segmentsTextArray = [[program_date allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        //                    // UIApplicationShortcutIcon
        //                    // UIApplicationShortcutItem
        //                    if(NSClassFromString(@"UIApplicationShortcutItem")) {
        //                        NSMutableArray *shortcutItems = [NSMutableArray new];
        //
        //                        for (NSDictionary *scenario in scenarios) {
        //                            NSString *id = [scenario objectForKey:@"id"];
        //                            if ([id rangeOfString:@"day" options:NSCaseInsensitiveSearch].length > 0) {
        //                                NSTimeInterval available = [[NSDate dateWithTimeIntervalSince1970:[[scenario objectForKey:@"available_time"] doubleValue]] timeIntervalSince1970];
        //                                NSTimeInterval expire = [[NSDate dateWithTimeIntervalSince1970:[[scenario objectForKey:@"expire_time"] doubleValue]] timeIntervalSince1970];
        //                                NSTimeInterval now = [[NSDate new] timeIntervalSince1970];
        //                                if (([id rangeOfString:@"day1" options:NSCaseInsensitiveSearch].length > 0 && now <= expire) || (now >= available && now <= expire)) {
        //                                    UIApplicationShortcutIconType iconType = [scenario objectForKey:@"used"] != nil
        //                                    ? UIApplicationShortcutIconTypeTaskCompleted
        //                                    : UIApplicationShortcutIconTypeTask;
        //                                    [shortcutItems addObject:[[UIApplicationShortcutItem alloc] initWithType:@"Checkin"
        //                                                                                              localizedTitle:NSLocalizedString(id, nil)
        //                                                                                           localizedSubtitle:nil
        //                                                                                                        icon:[UIApplicationShortcutIcon iconWithType:iconType]
        //                                                                                                    userInfo:@{
        //                                                                                                               @"key": id
        //                                                                                                               }]];
        //                                }
        //                            }
        //                        }
        //
        //                        for (NSString *dateText in segmentsTextArray) {
        //                            [shortcutItems addObject:[[UIApplicationShortcutItem alloc] initWithType:@"Session"
        //                                                                                      localizedTitle:dateText
        //                                                                                   localizedSubtitle:@"議程"
        //                                                                                                icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeDate]
        //                                                                                            userInfo:@{
        //                                                                                                       @"segmentsTextArray": segmentsTextArray,
        //                                                                                                       @"program_date": program_date
        //                                                                                                       }]];
        //                        }
        //
        //                        [[UIApplication sharedApplication] setShortcutItems:shortcutItems];
        //                    }
        //                }
        //            } failure:^(NSURLSessionTask *operation, NSError *error) {
        //                NSLog(@"Error: %@", error);
        //            }];
        //        }
        //    } failure:^(NSURLSessionTask *operation, NSError *error) {
        //        NSLog(@"Error: %@", error);
        //    }];
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        //
        return nil
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        //
    }
}


extension UIView {
    static var appDelegate: AppDelegate {
        return AppDelegate.delegateInstance
    }

    func registerForceTouch() {
        (self.next as! UIViewController).registerForceTouch()
    }
}

extension UIViewController {
    static var appDelegate: AppDelegate {
        return AppDelegate.delegateInstance
    }

    func registerForceTouch() {
        if self.traitCollection.responds(to: #selector(getter: UITraitCollection.forceTouchCapability)) && self.traitCollection.forceTouchCapability == .available {
            self.registerForPreviewing(with: self as! UIViewControllerPreviewingDelegate, sourceView: self.view)
        }
    }

    func previewActions() -> Array<UIPreviewActionItem> {
        struct preview {
            static var actions: Array<UIPreviewActionItem>?
        }

        if preview.actions == nil {
//            UIPreviewAction *printAction = [UIPreviewAction
//                actionWithTitle:@"Print"
//                style:UIPreviewActionStyleDefault
//                handler:^(UIPreviewAction * _Nonnull action,
//                UIViewController * _Nonnull previewViewController) {
//                // ... code to handle action here
//                }];
//            previewActions = @[ printAction ];
            preview.actions = []
        }
        return preview.actions!
    }
}
