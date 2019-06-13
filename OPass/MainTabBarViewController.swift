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
        let titleHighlightedColor = AppDelegate.appConfigColor("HighlightedColor")
        UITabBarItem.appearance()
            .setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], for: .normal)
        UITabBarItem.appearance()
            .setTitleTextAttributes([NSAttributedString.Key.foregroundColor: titleHighlightedColor], for: .selected)

        NotificationCenter.default.addObserver(self, selector: #selector(MainTabBarViewController.appplicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)

        // setting selected image color from original image with replace custom color filter
        for item in self.tabBar.items! {
            var image: UIImage = item.image!.withRenderingMode(.alwaysOriginal)
            image = image.imageWithColor(titleHighlightedColor)
            item.selectedImage = image.withRenderingMode(.alwaysOriginal)
            item.title = NSLocalizedString(item.title!, comment: "")
        }

        // self.automaticallyAdjustsScrollViewInsets = false;
        if #available(iOS 13.0, *) {
            // temporary remove this for non-iOS 13 and non-Xcode 11
            // overrideUserInterfaceStyle = .light
        }
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
