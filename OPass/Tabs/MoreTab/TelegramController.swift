//
//  TelegramController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/5.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation

class TelegramController : OPassWebViewController, OPassWebViewIB {
    @IBOutlet var goReloadButton: UIBarButtonItem?

    @IBAction override func reload(_ sender: Any) {
        super.reload(sender);
    }

    var PageUrl: String = ""

    override func viewWillAppear(_ animated: Bool) {
        self.PageUrl = Constants.URL_TELEGRAM_GROUP
        super.viewWillAppear(animated)
    }
}
