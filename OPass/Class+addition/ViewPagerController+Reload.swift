//
//  ViewPagerController+Reload.swift
//  OPass
//
//  Created by secminhr on 2021/5/8.
//  2021 OPass.
//

//Provide a way to reload data without the side effect of the change of selected tab, which loadData does.
import Foundation
@objc extension ViewPagerController {
    func reload(keepSelectedIndex keep: Bool) {
        if keep {
            let selectedIndex = self.activeTabIndex
            reloadData()
            self.selectTab(at: selectedIndex)
        } else {
            reloadData()
        }
    }
}
