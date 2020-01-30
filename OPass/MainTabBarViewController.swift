//
//  MainTabBarViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/2/8.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarViewController : UITabBarController {
    override func viewDidLoad() {
        UITabBarItem.appearance()
            .setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], for: .normal)
        UITabBarItem.appearance()
            .setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Constants.appConfigColor("HighlightedColor")], for: .selected)

        NotificationCenter.default.addObserver(self, selector: #selector(MainTabBarViewController.appplicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)

        OPassAPI.initTabBar(self)
        OPassAPI.refreshTabBar()

        // self.automaticallyAdjustsScrollViewInsets = false;
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        NSLog("User Token: <\(Constants.accessToken ?? "n/a")>")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.handleShortcutItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.handleShortcutItem()
    }

    @objc func appplicationDidBecomeActive(_ notification: NSNotification) {
        NSLog("Application Did Become Active")
        self.handleShortcutItem()
    }

    func handleShortcutItem() {
        let mainTabBarViewIndexObj = UserDefaults.standard.object(forKey: "MainTabBarViewIndex")
        if ((mainTabBarViewIndexObj) != nil) {
            let index = (mainTabBarViewIndexObj as? NSNumber)?.intValue
            self.selectedIndex = index!
            UserDefaults.standard.removeObject(forKey: "MainTabBarViewIndex")

            self.navigationController?.popToRootViewController(animated: true)
        }
        UserDefaults.standard.synchronize();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
}
