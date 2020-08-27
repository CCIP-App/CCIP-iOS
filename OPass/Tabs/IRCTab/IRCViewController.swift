//
//  IRCViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/5.
//  2018 OPass.
//

import Foundation

class IRCViewController: OPassWebViewController, OPassWebViewIB {
    @IBOutlet var goReloadButton: UIBarButtonItem?
    @IBOutlet var goBackButton: UIBarButtonItem?
    @IBOutlet var goForwardButton: UIBarButtonItem?

    @IBAction override func reload(_ sender: Any) {
        super.reload(sender);
    }

    @IBAction override func goBack(_ sender: Any) {
        super.goBack(sender);
    }

    @IBAction override func goForward(_ sender: Any) {
        super.goForward(sender);
    }

    var titleTextColor: String = "IRCTitleTextColor";
    var titleLeftColor: String = "IRCTitleLeftColor";
    var titleRightColor: String = "IRCTitleRightColor";
    var PageUrl: String = "";
    var ShowLogo: Bool = true;

    override func viewWillAppear(_ animated: Bool) {
        self.PageUrl = Constants.URL_LOG_BOT
        super.viewWillAppear(animated)
    }
}
