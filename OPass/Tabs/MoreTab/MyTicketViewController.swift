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

class MyTicketViewController: UIViewController {
    @IBOutlet var lbNotice: UILabel?
    @IBOutlet var ivQRCode: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let title = self.navigationItem.title else { return }
        guard let titles = title.split(separator: "\t").last else { return }
        self.navigationItem.title = titles.trim()
        var noticeText: String = NSLocalizedString("TicketNonExistNotice", comment: "")
        if (Constants.haveAccessToken) {
            guard let token = Constants.accessToken else { return }
            guard let size = self.ivQRCode?.frame.size else { return }
            if let QRImage = EFQRCode.generate(
                    token,
                    size: size,
                    backgroundColor: UIColor.white.cgColor,
                    foregroundColor: UIColor.black.cgColor,
                    watermark: nil
                ) {
                let qrImage = UIImage.init(cgImage: QRImage)
                self.ivQRCode?.image = qrImage;
                noticeText = NSLocalizedString("TicketNotice", comment: "")
            }
        }
        self.lbNotice?.text = noticeText
        self.lbNotice?.textColor = Constants.appConfigColor("CardTextColor")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
