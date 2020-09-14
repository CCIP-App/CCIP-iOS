//
//  CheckinCardView.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  2019 OPass.
//

import Foundation
import UIKit

class CheckinCardView: UIView {
    @IBOutlet public var checkinSmallCard: UIView?
    @IBOutlet public var checkinDate: UILabel?
    @IBOutlet public var checkinTitle: UILabel?
    @IBOutlet public var checkinText: UILabel?
    @IBOutlet public var checkinBtn: UIButton?
    @IBOutlet public var checkinIcon: UIImageView?

    public var delegate: CheckinViewController?
    public var scenario: Scenario?
    public var id: String = ""
    public var used: Int?
    public var disabled: String?

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        self.checkinBtn?.sizeGradientToFit()
    }

    func showCountdown() {
        if let _scenario = self.scenario {
            let date = Date.init(timeIntervalSince1970: TimeInterval(_scenario.Used ?? 0))
            let stopDate = date.addingTimeInterval(TimeInterval(_scenario.Countdown ?? 0))
            let now = Date.init()
            NSLog("\(date) ~ \(stopDate) == \(now)")
            // always display countdown for t-shirt view
            // if ([now timeIntervalSince1970] - [stopDate timeIntervalSince1970] < 0) {
            self.delegate?.showCountdown(_scenario)
            // }
        }
    }

    func updateScenario(_ scenarios: [Scenario]) -> Scenario {
        for scenario in scenarios {
            if scenario.Id == self.id {
                self.scenario = scenario
                self.used = scenario.Used
                break
            }
        }
        guard let _scenario = self.scenario else {
            return Scenario.init("")
        }
        return _scenario
    }

    func use(_ isCheckin: Bool) {
        if (self.scenario?.Used != nil) {
            self.showCountdown()
            OPassAPI.buttonStyleUpdate({
                self.checkinBtn?.setGradientColor(from: .orange, to: Constants.appConfigColor.CheckinButtonRightColor, startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
            }, {
                self.checkinBtn?.setGradientColor(from: Constants.appConfigColor.UsedButtonLeftColor, to: Constants.appConfigColor.UsedButtonRightColor, startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
            }, nil)
        } else {
            OPassAPI.UseScenario(OPassAPI.currentEvent, Constants.accessToken ?? "", self.id) { (success, obj, error) in
                if success {
                    if let status = obj as? ScenarioStatus {
                        let _ = self.updateScenario((status).Scenarios)
                    }
                    self.showCountdown()
                    OPassAPI.buttonStyleUpdate({
                        self.checkinBtn?.setGradientColor(from: Constants.appConfigColor.DisabledButtonLeftColor, to: Constants.appConfigColor.DisabledButtonRightColor, startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
                    }, nil, nil)
                    if isCheckin {
                        self.checkinBtn?.setTitle(NSLocalizedString("CheckinViewButtonPressed", comment: ""), for: .normal)
                        AppDelegate.delegateInstance.checkinView?.reloadCard()
                    } else {
                        self.checkinBtn?.setTitle(NSLocalizedString("UseButtonPressed", comment: ""), for: .normal)
                    }
                    AppDelegate.delegateInstance.setDefaultShortcutItems()
                } else {
                    func broken(_ msg: String = "Networking_Broken") {
                        self.delegate?.showInvalidNetworkMsg(NSLocalizedString(msg, comment: ""))
                    }
                    guard let sr = obj as? OPassNonSuccessDataResponse else {
                        if let info: NSDictionary = error._userInfo as? NSDictionary {
                            if let _: HTTPURLResponse = info["com.alamofire.serialization.response.error.response"] as? HTTPURLResponse {
                                //
                            } else {
                                broken()
                            }
                        }
                        return
                    }
                    switch (sr.Response?.statusCode) {
                    case 400:
                        guard let responseObject = sr.Obj as? NSDictionary else { return }
                        let msg = responseObject.value(forKeyPath: "json.message") as? String ?? ""
                        NSLog("msg: \(msg)")
                        switch (msg) {
                        case "invalid token":
                            OPassAPI.buttonStyleUpdate({
                                self.checkinBtn?.setGradientColor(from: .red, to: Constants.appConfigColor.CheckinButtonRightColor, startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
                            }, nil, nil)
                        case "has been used":
                            self.showCountdown()
                            OPassAPI.buttonStyleUpdate({
                                self.checkinBtn?.setGradientColor(from: .orange, to: Constants.appConfigColor.CheckinButtonRightColor, startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
                            }, {
                                self.checkinBtn?.setGradientColor(from: Constants.appConfigColor.UsedButtonLeftColor, to: Constants.appConfigColor.UsedButtonRightColor, startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
                            }, nil)
                        case "link expired/not available now":
                            OPassAPI.buttonStyleUpdate({
                                self.checkinBtn?.setGradientColor(from: .orange, to: Constants.appConfigColor.CheckinButtonRightColor, startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
                            }, {
                                self.checkinBtn?.setGradientColor(from: Constants.appConfigColor.CheckinButtonLeftColor, to: Constants.appConfigColor.CheckinButtonRightColor, startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
                            }) {
                                self.checkinBtn?.setTitle(NSLocalizedString(isCheckin ? "CheckinViewButton" : "UseButton", comment: ""), for: .normal)
                            }
                        default:
                            break
                        }
                    case 403:
                        broken("Networking_WrongWiFi")
                    default:
                        broken()
                    }
                }
            }
        }
    }

    func processDisabled() -> UIImpactFeedbackType? {
        UIView.animate(withDuration: 0.25, animations: {
            self.checkinBtn?.setGradientColor(from: .orange, to: Constants.appConfigColor.CheckinButtonRightColor, startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
        }) { finished in
            if finished {
                UIView.animate(withDuration: 1.75) {
                    self.checkinBtn?.setGradientColor(from: Constants.appConfigColor.DisabledButtonLeftColor, to: Constants.appConfigColor.DisabledButtonLeftColor, startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
                }
            }
        }
        Constants.SendFib("CheckinCardView", WithEvents: ["Click": "click_disabled"])
        return .notificationFeedbackWarning
    }

    func processInTime(_ ac: inout UIAlertController?, _ isCheckin: Bool, _ nowTime: Date, _ availableTime: Date, _ expireTime: Date) -> UIImpactFeedbackType? {
        if isCheckin {
            self.use(isCheckin)
        } else if ((self.used) != nil) {
            self.use(isCheckin)
        } else {
            if let _scenario = self.scenario {
                if ((_scenario.Countdown ?? 0) > 0) {
                    ac = UIAlertController.alertOfTitle(NSLocalizedString("ConfirmAlertText", comment: ""), withMessage: nil, cancelButtonText: NSLocalizedString("Cancel", comment: ""), cancelStyle: .cancel, cancelAction: nil)
                    ac?.addActionButton(NSLocalizedString("CONFIRM", comment: ""), style: .destructive, handler: { _ in
                        self.use(isCheckin)
                    })
                } else {
                    self.use(isCheckin)
                }
            }
        }
        return nil
    }

    func processOutTime(_ ac: inout UIAlertController?, _ isCheckin: Bool, _ nowTime: Date, _ availableTime: Date, _ expireTime: Date) -> UIImpactFeedbackType? {
        if nowTime.compare(availableTime) == .orderedAscending {
            ac = UIAlertController.alertOfTitle(NSLocalizedString("NotAvailableTitle", comment: ""), withMessage: NSLocalizedString("NotAvailableMessage", comment: ""), cancelButtonText: NSLocalizedString("NotAvailableButtonOk", comment: ""), cancelStyle: .destructive, cancelAction: nil)
            return .notificationFeedbackError
        }
        if nowTime.compare(expireTime) == .orderedDescending || self.used != nil {
            ac = UIAlertController.alertOfTitle(NSLocalizedString("ExpiredTitle", comment: ""), withMessage: NSLocalizedString("ExpiredMessage", comment: ""), cancelButtonText: NSLocalizedString("ExpiredButtonOk", comment: ""), cancelStyle: .destructive, cancelAction: nil)
            return .notificationFeedbackError
        }
        return nil
    }

    @IBAction func checkinBtnTouched(_ sender: Any) {
        var ac: UIAlertController? = nil
        var feedbackType: UIImpactFeedbackType? = UIImpactFeedbackType(rawValue: 0)
        let nowTime = Date.init()
        let availableTime = Date.init(timeIntervalSince1970: TimeInterval(self.scenario?.AvailableTime ?? 0))
        let expireTime = Date.init(timeIntervalSince1970: TimeInterval(self.scenario?.ExpireTime ?? 0))
        let isCheckin = ((OPassAPI.ParseScenarioType(self.id)["scenarioType"] as? String) ?? "").contains("checkin")

        if self.disabled != nil {
            feedbackType = self.processDisabled()
        } else {
            if nowTime.compare(availableTime) != .orderedAscending && nowTime.compare(expireTime) != .orderedDescending {
                // IN TIME
                feedbackType = self.processInTime(&ac, isCheckin, nowTime, availableTime, expireTime)
            } else {
                // OUT TIME
                feedbackType = self.processOutTime(&ac, isCheckin, nowTime, availableTime, expireTime)
            }
        }
        // only out time or need confirm will display alert controller
        let triggerFeedback = {
            if let feedback = feedbackType {
                UIImpactFeedback.triggerFeedback(feedback)
            }
        }
        if (ac != nil) {
            ac?.showAlert {
                triggerFeedback()
            }
        } else {
            triggerFeedback()
        }
    }
}
