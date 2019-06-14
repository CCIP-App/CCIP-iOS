//
//  CheckinCardViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/14.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import UIKit

class CheckinCardViewController: UIViewController {
    @IBOutlet public weak var checkinSmallCard: UIView!
    @IBOutlet public weak var checkinDate: UILabel!
    @IBOutlet public weak var checkinTitle: UILabel!
    @IBOutlet public weak var checkinText: UILabel!
    @IBOutlet public weak var checkinBtn: UIButton!
    @IBOutlet public weak var checkinIcon: UIImageView!
    public var delegate: CheckinViewController?
    public var scenario: NSDictionary?
    public var id: NSString?
    public var used: NSNumber?
    public var disabled: NSNumber?

    private var cardView: CheckinCardView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.cardView = self.view as? CheckinCardView

        let csc = self.cardView!.checkinSmallCard!
        csc.layer.cornerRadius = 5
        csc.layer.masksToBounds = false
        csc.layer.shadowOffset = CGSize(width: 0, height: 50)
        csc.layer.shadowRadius = 50
        csc.layer.shadowOpacity = 0.1
    }

    override func viewDidLayoutSubviews() {
        guard let checkinBtn = self.cardView?.checkinBtn else { return }
        guard let layer = checkinBtn.layer.sublayers?.first else { return }
        layer.cornerRadius = checkinBtn.frame.size.height / 2
        checkinBtn.layer.cornerRadius = checkinBtn.frame.size.height / 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func setScenario(_ scenario: NSDictionary) {
        self.cardView?.scenario = scenario as? [AnyHashable : Any]
        guard let id = scenario.object(forKey: "id") as? String else { return }

        if id == "vipkit" && scenario.object(forKey: "disabled") == nil {
            self.cardView?.layer.shadowColor = UIColor.colorFromHtmlColor("#cff1").cgColor
            self.cardView?.layer.shadowRadius = 20
            let animation = CABasicAnimation.init(keyPath: "shadowOpacity")
            animation.fromValue = 0.3
            animation.toValue = 0.5
            animation.repeatCount = HUGE
            animation.duration = 1
            animation.autoreverses = true
            animation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
            self.cardView?.layer.add(animation, forKey: "pulse")
        }
    }

    @objc func setId(_ id: String) {
        self.cardView!.id = id
    }

    @objc func setUsed(_ used: NSNumber) {
        self.cardView!.used = used
    }

    @objc func setDisabled(_ disabled: NSNumber) {
        self.cardView!.disabled = disabled
    }

    @objc func setDelegate(_ delegate: CheckinViewController) {
        self.cardView!.delegate = delegate
    }
}
