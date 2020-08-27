//
//  CheckinCardViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/14.
//  2019 OPass.
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
    public var scenario: Dictionary<String, NSObject>?
    public var id: String = ""
    public var used: Int?
    public var disabled: String?

    private var cardView: CheckinCardView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.cardView = self.view as? CheckinCardView

        if let csc = self.cardView?.checkinSmallCard {
            csc.layer.cornerRadius = 5
            csc.layer.masksToBounds = false
            csc.layer.shadowOffset = CGSize(width: 0, height: 50)
            csc.layer.shadowRadius = 50
            csc.layer.shadowOpacity = 0.1
        }
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

    func setScenario(_ scenario: Scenario?) {
        self.cardView?.scenario = scenario
        guard let id = scenario?.Id else { return }

        if id == "vipkit" && scenario?.Disabled == nil {
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

    func setId(_ id: String) {
        self.cardView?.id = id
    }

    func setUsed(_ used: Int?) {
        self.cardView?.used = used
    }

    func setDisabled(_ disabled: String?) {
        self.cardView?.disabled = disabled
    }

    func setDelegate(_ delegate: CheckinViewController) {
        self.cardView?.delegate = delegate
    }
}
