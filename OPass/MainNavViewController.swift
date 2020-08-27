//
//  MainNavViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  2018 OPass.
//

import Foundation
import UIKit

@objcMembers class MainNavViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view.

        self.view.backgroundColor = UIColor.white;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }

    override var prefersStatusBarHidden: Bool {
        return false;
    }
}
