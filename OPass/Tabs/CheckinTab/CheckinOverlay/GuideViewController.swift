//
//  GuideViewController.swift
//  OPass
//
//  Created by FrankWu on 2019/6/17.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import UIKit
import AFNetworking
import UICKeyChainStore

class GuideViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var guideMessageLabel: UILabel!
    @IBOutlet weak var redeemCodeText: UITextField!
    @IBOutlet weak var redeemButton: UIButton!
    
    private var isRelayout = false
    private var changePoint = CGPoint.zero

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guideMessageLabel.text = NSLocalizedString("GuideViewMessage", comment: "")
        
        redeemCodeText.textColor = AppDelegate.appConfigColor("RedeemCodeTextColor")
        
        redeemButton.setTitle(NSLocalizedString("GuideViewButton", comment: ""), for: .normal)
        redeemButton.tintColor = UIColor.white
        redeemButton.backgroundColor = UIColor(red: 61 / 255.0, green: 152 / 255.0, blue: 60 / 255.0, alpha: 1)
        redeemButton.layer.cornerRadius = 7.0
        
        // Set carousel background linear diagonal gradient
        //   Create the colors
        let topColor = AppDelegate.appConfigColor("RedeemButtonLeftColor")
        let bottomColor = AppDelegate.appConfigColor("RedeemButtonRightColor")
        //   Create the gradient
        let theViewGradient = CAGradientLayer()
        theViewGradient.colors = [topColor.cgColor, bottomColor.cgColor]
        theViewGradient.frame = CGRect(x: 0, y: 0, width: redeemButton.frame.size.width, height: redeemButton.frame.size.height)
        theViewGradient.startPoint = CGPoint(x: 1, y: 0.5)
        theViewGradient.endPoint = CGPoint(x: 0, y: 0.2)
        theViewGradient.cornerRadius = 7.0
        //   Add gradient to view
        redeemButton.layer.insertSublayer(theViewGradient, at: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GuideViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GuideViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GuideViewController.appplicationDidEnterBackground(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        
        // SEND_FIB("GuideViewController")
        
        view.autoresizingMask = []
    }
    
    @objc func appplicationDidEnterBackground(_ notification: Notification?) {
        dismiss(animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismiss(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        redeemCode(nil)
        return true
    }
    
    @objc func keyboardWillShow(_ note: Notification?) {
        if view.frame.size.height <= 480 {
            changePoint = CGPoint(x: 0, y: -165)
            
            var guideMessageLabelFrame = guideMessageLabel.frame
            guideMessageLabelFrame.origin.y += changePoint.y
            guideMessageLabel.frame = guideMessageLabelFrame
            
            var redeemCodeTextFrame = redeemCodeText.frame
            redeemCodeTextFrame.origin.y += changePoint.y
            redeemCodeText.frame = redeemCodeTextFrame
            
            var redeemButtonFrame = redeemButton.frame
            redeemButtonFrame.origin.y += changePoint.y
            redeemButton.frame = redeemButtonFrame
        } else if view.frame.size.height <= 568 {
            changePoint = CGPoint(x: 0, y: -30)
            
            var guideMessageLabelFrame = guideMessageLabel.frame
            guideMessageLabelFrame.origin.y += changePoint.y
            guideMessageLabel.frame = guideMessageLabelFrame
            
            var redeemCodeTextFrame = redeemCodeText.frame
            redeemCodeTextFrame.origin.y += changePoint.y
            redeemCodeText.frame = redeemCodeTextFrame
            
            var redeemButtonFrame = redeemButton.frame
            redeemButtonFrame.origin.y += changePoint.y
            redeemButton.frame = redeemButtonFrame
        }
    }
    
    @objc func keyboardWillHide(_ note: Notification?) {
        let deltaH: CGFloat = changePoint.y * -1
        
        var guideMessageLabelFrame = guideMessageLabel.frame
        guideMessageLabelFrame.origin.y += deltaH
        guideMessageLabel.frame = guideMessageLabelFrame
        
        var redeemCodeTextFrame = redeemCodeText.frame
        redeemCodeTextFrame.origin.y += deltaH
        redeemCodeText.frame = redeemCodeTextFrame
        
        var redeemButtonFrame = redeemButton.frame
        redeemButtonFrame.origin.y += deltaH
        redeemButton.frame = redeemButtonFrame
        
        changePoint = CGPoint(x: 0, y: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func redeemCode(_ sender: Any?) {
        var alreadyAlert = false
        OPassAPI.RedeemCode(forEvent: "", withToken: redeemCodeText.text!) { success, obj, error in
            if success {
                self.dismiss(animated: true)
            } else {
                if !alreadyAlert {
                    alreadyAlert = true
                    self.showAlert()
                }
            }
        }
    }

    func showAlert() {
        let ac = UIAlertController.alertOfTitle(NSLocalizedString("GuideViewTokenErrorTitle", comment: ""), withMessage: NSLocalizedString("GuideViewTokenErrorDesc", comment: ""), cancelButtonText: NSLocalizedString("GotIt", comment: ""), cancelStyle: UIAlertAction.Style.cancel, cancelAction: nil)
        ac.showAlert({
            UIImpactFeedback.triggerFeedback(UIImpactFeedbackType.notificationFeedbackError)
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
