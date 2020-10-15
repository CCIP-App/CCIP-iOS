//
//  GuideViewController.swift
//  OPass
//
//  Created by FrankWu on 2019/6/17.
//  2019 OPass.
//

import Foundation
import UIKit
import AFNetworking
import UICKeyChainStore

class GuideViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var guideMessageLabel: UILabel!
    @IBOutlet weak var guideLineLabel: UILabel!
    @IBOutlet weak var redeemCodeText: UITextField!
    @IBOutlet weak var redeemButton: UIButton!

    private var isRelayout = false
    private var changePoint = CGPoint.zero

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guideMessageLabel.text = NSLocalizedString("GuideViewMessage", comment: "")

        redeemCodeText.textColor = Constants.appConfigColor.RedeemCodeTextColor

        redeemButton.setTitle(NSLocalizedString("GuideViewButton", comment: ""), for: .normal)
        redeemButton.tintColor = .white
        redeemButton.backgroundColor = UIColor(red: 61 / 255.0, green: 152 / 255.0, blue: 60 / 255.0, alpha: 1)
        redeemButton.layer.cornerRadius = 7

        // Set carousel background linear diagonal gradient
        //   Create the colors
        let topColor: UIColor = Constants.appConfigColor.RedeemButtonLeftColor
        let bottomColor: UIColor = Constants.appConfigColor.RedeemButtonRightColor
        //   Create the gradient
        let theViewGradient = CAGradientLayer()
        theViewGradient.colors = [topColor.cgColor, bottomColor.cgColor]
        theViewGradient.frame = CGRect(x: 0, y: 0, width: redeemButton.frame.size.width, height: redeemButton.frame.size.height)
        theViewGradient.startPoint = CGPoint(x: 1, y: 0.5)
        theViewGradient.endPoint = CGPoint(x: 0, y: 0.2)
        theViewGradient.cornerRadius = 7
        //   Add gradient to view
        redeemButton.layer.insertSublayer(theViewGradient, at: 0)

        NotificationCenter.default.addObserver(self, selector: #selector(GuideViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GuideViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GuideViewController.appplicationDidEnterBackground(_:)), name: UIApplication.willResignActiveNotification, object: nil)

        Constants.SendFib("GuideViewController")

        view.autoresizingMask = []
    }

    @objc func appplicationDidEnterBackground(_ notification: Notification?) {
        self.dismiss(animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.redeemCode(nil)
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.phase == .began {
                self.redeemCodeText.resignFirstResponder()
            }
        }
    }

    @objc func keyboardWillShow(_ note: Notification?) {
        if self.changePoint.y != 0 {
            return
        }
        if view.frame.size.height <= 480 {
            self.changePoint.y = -30
        } else if view.frame.size.height <= 768 {
            self.changePoint.y = -165
        }
        self.moveOjectsByOffset(self.changePoint.y)
    }

    @objc func keyboardWillHide(_ note: Notification?) {
        self.moveOjectsByOffset(self.changePoint.y * -1)
        self.changePoint.y = 0
    }

    func moveOjectsByOffset(_ dy: CGFloat) {
        var guideMessageLabelFrame = self.guideMessageLabel.frame
        guideMessageLabelFrame.origin.y += dy
        self.guideMessageLabel.frame = guideMessageLabelFrame

        var guideLineLabelFrame = self.guideLineLabel.frame
        guideLineLabelFrame.origin.y += dy
        self.guideLineLabel.frame = guideLineLabelFrame

        var redeemCodeTextFrame = self.redeemCodeText.frame
        redeemCodeTextFrame.origin.y += dy
        self.redeemCodeText.frame = redeemCodeTextFrame

        var redeemButtonFrame = self.redeemButton.frame
        redeemButtonFrame.origin.y += dy
        self.redeemButton.frame = redeemButtonFrame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func redeemCode(_ sender: Any?) {
        var alreadyAlert = false
        self.redeemButton.isEnabled = false
        OPassAPI.RedeemCode(forEvent: "", withToken: redeemCodeText.text ?? "") { success, _, _ in
            if success {
                self.dismiss(animated: true)
            } else {
                if !alreadyAlert {
                    alreadyAlert = true
                    self.showAlert()
                }
            }
            self.redeemButton.isEnabled = true
        }
    }

    func showAlert() {
        let ac = UIAlertController.alertOfTitle(NSLocalizedString("GuideViewTokenErrorTitle", comment: ""), withMessage: NSLocalizedString("GuideViewTokenErrorDesc", comment: ""), cancelButtonText: NSLocalizedString("GotIt", comment: ""), cancelStyle: .cancel, cancelAction: nil)
        ac.showAlert({
            UIImpactFeedback.triggerFeedback(.notificationFeedbackError)
        })
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }
}
