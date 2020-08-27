//
//  InvalidNetworkMessageViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  2019 OPass.
//

import Foundation
import UIKit

class InvalidNetworkMessageViewController: UIViewController {
    public var delegate: InvalidNetworkRetryDelegate?
    public var message: String = ""
    @IBOutlet public var messageLabel: UILabel?
    @IBOutlet public var closeButton: UIButton?

    private var isRelayout: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.closeButton?.setTitle(NSLocalizedString("InvalidNetworkButtonRetry", comment: ""), for: .normal)
        self.closeButton?.tintColor = .white
        self.closeButton?.backgroundColor = UIColor.init(red: 61 / 255.0, green: 152 / 255.0, blue: 60 / 255.0, alpha: 1)
        self.closeButton?.setGradientColor(from: Constants.appConfigColor.MessageButtonLeftColor, to: Constants.appConfigColor.MessageButtonRightColor, startPoint: CGPoint(x: -0.4, y: 0.5), toPoint: CGPoint(x: 1, y: 0.5))
        if let layer = self.closeButton?.layer.sublayers?.first {
            layer.cornerRadius = (self.closeButton?.frame.size.height ?? 2) / 2
            self.closeButton?.layer.cornerRadius = (self.closeButton?.frame.size.height ?? 2) / 2
        }

        self.messageLabel?.text = self.message
        self.view.autoresizingMask = []
        NotificationCenter.default.addObserver(self, selector: #selector(InvalidNetworkMessageViewController.appplicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !self.isRelayout {
            if let mnvc: MainNavViewController = self.presentingViewController as? MainNavViewController {
                if let cvc: InvalidNetworkRetryDelegate = mnvc.children.first as? InvalidNetworkRetryDelegate{
                    let topStart = cvc.controllerTopStart
                    self.view.frame = CGRect(x: 0, y: 0 - topStart, width: self.view.frame.size.width, height: self.view.frame.size.height + topStart)
                    self.isRelayout = true
                }
            }
        }
    }

    @IBAction func closeView(_ sender: NSObject) {
        self.dismiss(animated: true) {
            self.delegate?.refresh?()
        }
    }

    @objc func appplicationDidEnterBackground(_ notification: NSNotification) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }
}
