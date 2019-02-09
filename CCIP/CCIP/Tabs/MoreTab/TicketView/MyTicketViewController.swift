//
//  MyTicketViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/2/8.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import UIKit
import EFQRCode

@objc class MyTicketViewController : UIViewController {
    @IBOutlet var lbNotice: UILabel?
    @IBOutlet var ivQRCode: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var noticeText: String = NSLocalizedString("TicketNonExistNotice", comment: "")
        if (AppDelegate.haveAccessToken()) {
            if let QRImage = EFQRCode.generate(
                    AppDelegate.accessToken(),
                    size: (self.ivQRCode?.frame.size)!,
                    backgroundColor: CGColor.EFWhite(),
                    foregroundColor: CGColor.EFBlack(),
                    watermark: nil
                ) {
                let qrImage = UIImage.init(cgImage: QRImage)
                self.ivQRCode?.image = qrImage;
                noticeText = NSLocalizedString("TicketNotice", comment: "")
            }
        }
        self.lbNotice!.text = noticeText
        self.lbNotice?.textColor = AppDelegate.appConfigColor("CardTextColor")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
