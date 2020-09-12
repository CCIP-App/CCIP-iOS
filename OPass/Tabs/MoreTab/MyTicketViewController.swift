//
//  MyTicketViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/2/8.
//  2019 OPass.
//

import Foundation
import UIKit
import AudioToolbox
import EFQRCode

class MyTicketViewController: UIViewController {
    @IBOutlet var lbNotice: UILabel!
    @IBOutlet var ivQRCode: UIImageView!
    @IBOutlet var btnLogout: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let title = self.navigationItem.title else { return }
        guard let titles = title.split(separator: "\t").last else { return }
        self.navigationItem.title = titles.trim()
        var noticeText: String = NSLocalizedString("TicketNonExistNotice", comment: "")
        var logoutTitle: String = NSLocalizedString("TicketLogout", comment: "")
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
                self.ivQRCode.image = qrImage;
                noticeText = NSLocalizedString("TicketNotice", comment: "")
            }
        } else {
            logoutTitle = ""
        }
        self.lbNotice.text = noticeText
        self.lbNotice.textColor = Constants.appConfigColor.CardTextColor
        self.btnLogout.setTitle(logoutTitle, for: .normal)
        self.btnLogout.setGradientColor(from: Constants.appConfigColor.RedeemButtonLeftColor, to: Constants.appConfigColor.RedeemButtonRightColor, startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
        self.btnLogout.isHidden = logoutTitle.count == 0
        guard let layer = self.btnLogout.layer.sublayers?.first else { return }
        layer.cornerRadius = self.btnLogout.frame.size.height / 2
        self.btnLogout.layer.cornerRadius = self.btnLogout.frame.size.height / 2
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if (!Constants.haveAccessToken) {
            self.performSegue(withIdentifier: "ShowGuide", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logoutAction(_ sender: Any) {
        let ac = UIAlertController.alertOfTitle(NSLocalizedString("TicketLogoutWarning", comment: ""), withMessage: NSLocalizedString("TicketLogoutWarningDesc", comment: ""), cancelButtonText: NSLocalizedString("Cancel", comment: ""), cancelStyle: .cancel) { _ in
        }
        ac.addActionButton(NSLocalizedString("Okay", comment: ""), style: .destructive) { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            OPassAPI.isLoginSession = false
            OPassAPI.userInfo = nil
            Constants.accessToken = ""
            self.dismiss(animated: true, completion: nil)
        }
        ac.showAlert {
            UIImpactFeedback.triggerFeedback(.notificationFeedbackError)
            OPassAPI.buttonStyleUpdate({
                self.btnLogout.setGradientColor(from: .orange, to: Constants.appConfigColor.CheckinButtonRightColor, startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
            }, {
                self.btnLogout.setGradientColor(from: Constants.appConfigColor.UsedButtonLeftColor, to: Constants.appConfigColor.UsedButtonRightColor, startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
            }, nil)
        }
    }
}
