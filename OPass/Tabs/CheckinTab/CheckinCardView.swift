//
//  CheckinCardView.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  Copyright © 2019 OPass. All rights reserved.
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
    public var scenario = Dictionary<String, NSObject>()
    public var id: String = ""
    public var used: Int = 0
    public var disabled: String = ""

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        self.checkinBtn?.sizeGradientToFit()
    }

    func showCountdown() {
        let date = Date.init(timeIntervalSince1970: TimeInterval(self.scenario["used"] as! Int))
        let stopDate = date.addingTimeInterval(TimeInterval(self.scenario["countdown"] as! Int))
        let now = Date.init()
        NSLog("\(date) ~ \(stopDate) == \(now)")
        // always display countdown for t-shirt view
        // if ([now timeIntervalSince1970] - [stopDate timeIntervalSince1970] < 0) {
        self.delegate?.showCountdown(self.scenario as NSDictionary)
        // }
    }

    func updateScenario(_ scenarios: Array<Dictionary<String, NSObject>>) -> Dictionary<String, NSObject> {
        for scenario in scenarios {
            let id = scenario["id"] as! String
            if id == self.id {
                self.scenario = scenario
                break
            }
        }
        return self.scenario
    }

    @IBAction func checkinBtnTouched(_ sender: Any) {
        var ac: UIAlertController? = nil
        var feedbackType: UIImpactFeedbackType? = UIImpactFeedbackType(rawValue: 0)
        let availableTime = Date.init(timeIntervalSince1970: TimeInterval(self.scenario["available_time"] as! Int))
        let expireTime = Date.init(timeIntervalSince1970: TimeInterval(self.scenario["expire_time"] as! Int))
        let nowTime = Date.init()
        let isCheckin = (AppDelegate.parseScenarioType(self.id)["scenarioType"] as! String) == "checkin"

        //    __block AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        let use = {
        //    void (^use)(void) = ^{
        //        NSString *useURL = [Constants URL_USEWithToken:[AppDelegate accessToken]
        //                                              scenario:self.id];
        //        NSURL *url = [NSURL URLWithString:useURL];
        //        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        //        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        //            NSLog(@"JSON: %@", responseObject);
        //            if (responseObject != nil) {
        //                [self setUsed:[NSNumber numberWithBool:YES]];
        //                if ([[responseObject objectForKey:@"message"] isEqual:@"invalid token"]) {
        //                    NSLog(@"%@", [responseObject objectForKey:@"message"]);
        //                    [self.checkinBtn setGradientColorFrom:[UIColor redColor]
        //                                                       to:[AppDelegate AppConfigColor:@"CheckinButtonRightColor"]
        //                                               startPoint:CGPointMake(.2, .8)
        //                                                  toPoint:CGPointMake(1, .5)];
        //                } else if ([[responseObject objectForKey:@"message"] isEqual:@"has been used"]) {
        //                    [self showCountdown];
        //                    NSLog(@"%@", [responseObject objectForKey:@"message"]);
        //                    [UIView animateWithDuration:.25f
        //                                     animations:^{
        //                                         [self.checkinBtn setGradientColorFrom:[UIColor orangeColor]
        //                                                                            to:[AppDelegate AppConfigColor:@"CheckinButtonRightColor"]
        //                                                                    startPoint:CGPointMake(.2, .8)
        //                                                                       toPoint:CGPointMake(1, .5)];
        //                                     }
        //                                     completion:^(BOOL finished) {
        //                                         if (finished) {
        //                                             [UIView animateWithDuration:1.75f
        //                                                              animations:^{
        //                                                                  [self.checkinBtn setGradientColorFrom:[AppDelegate AppConfigColor:@"UsedButtonLeftColor"]
        //                                                                                                     to:[AppDelegate AppConfigColor:@"UsedButtonRightColor"]
        //                                                                                             startPoint:CGPointMake(.2, .8)
        //                                                                                                toPoint:CGPointMake(1, .5)];
        //                                                              }];
        //                                         }
        //                                     }];
        //                } else if ([[responseObject objectForKey:@"message"] isEqual:@"link expired/not available now"]) {
        //                    NSLog(@"%@", [responseObject objectForKey:@"message"]);
        //                    [UIView animateWithDuration:.25f
        //                                     animations:^{
        //                                         [self.checkinBtn setGradientColorFrom:[UIColor orangeColor]
        //                                                                            to:[AppDelegate AppConfigColor:@"CheckinButtonRightColor"]
        //                                                                    startPoint:CGPointMake(.2, .8)
        //                                                                       toPoint:CGPointMake(1, .5)];
        //                                         [self.checkinBtn setTitle:NSLocalizedString(@"ExpiredOrNotAvailable", nil)
        //                                                          forState:UIControlStateNormal];
        //                                     }
        //                                     completion:^(BOOL finished) {
        //                                         if (finished) {
        //                                             [UIView animateWithDuration:1.75f
        //                                                              animations:^{
        //                                                                  [self.checkinBtn setGradientColorFrom:[AppDelegate AppConfigColor:@"CheckinButtonLeftColor"]
        //                                                                                                     to:[AppDelegate AppConfigColor:@"CheckinButtonRightColor"]
        //                                                                                             startPoint:CGPointMake(.2, .8)
        //                                                                                                toPoint:CGPointMake(1, .5)];
        //                                                              }
        //                                                              completion:^(BOOL finished) {
        //                                                                  if (finished) {
        //                                                                      [UIView animateWithDuration:.25f
        //                                                                                       animations:^{
        //                                                                                           [self.checkinBtn setTitle:NSLocalizedString(isCheckin ? @"CheckinViewButton" : @"UseButton", nil)
        //                                                                                                            forState:UIControlStateNormal];
        //                                                                                       }];
        //                                                                  }
        //                                                              }];
        //                                         }
        //                                     }];
        //                } else {
        //                    [self updateScenario:[responseObject objectForKey:@"scenarios"]];
        //                    [self showCountdown];
        //                    [self.checkinBtn setGradientColorFrom:[AppDelegate AppConfigColor:@"DisabledButtonLeftColor"]
        //                                                       to:[AppDelegate AppConfigColor:@"DisabledButtonRightColor"]
        //                                               startPoint:CGPointMake(.2, .8)
        //                                                  toPoint:CGPointMake(1, .5)];
        //                    if (isCheckin) {
        //                        [self.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButtonPressed", nil) forState:UIControlStateNormal];
        //                        [[AppDelegate delegateInstance].checkinView reloadCard];
        //                    } else {
        //                        [self.checkinBtn setTitle:NSLocalizedString(@"UseButtonPressed", nil) forState:UIControlStateNormal];
        //                    }
        //                    [[AppDelegate delegateInstance] setDefaultShortcutItems];
        //                }
        //            } else {
        //                // Invalid Network
        //                [self.delegate showInvalidNetworkMsg];
        //                // UIAlertController *ac = [UIAlertController alertOfTitle:NSLocalizedString(@"NetworkAlert", nil) withMessage:NSLocalizedString(@"NetworkAlertDesc", nil) cancelButtonText:NSLocalizedString(@"GotIt", nil) cancelStyle:UIAlertActionStyleCancel cancelAction:nil];
        //                // [ac showAlert:nil];
        //            }
        //        }];
        //        [dataTask resume];
        //    };
        }

        if self.disabled.count > 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.checkinBtn?.setGradientColor(from: .orange, to: AppDelegate.appConfigColor("CheckinButtonRightColor"), startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
            }) { finished in
                if finished {
                    UIView.animate(withDuration: 1.75) {
                        self.checkinBtn?.setGradientColor(from: AppDelegate.appConfigColor("DisabledButtonLeftColor"), to: AppDelegate.appConfigColor("DisabledButtonLeftColor"), startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
                    }
                }
            }
            Constants.SendFib("CheckinCardView", WithEvents: ["Click": "click_disabled"])
            feedbackType = .notificationFeedbackWarning
        } else {
            if nowTime.compare(availableTime) != .orderedAscending && nowTime.compare(expireTime) != .orderedDescending {
                // IN TIME
                if isCheckin {
                    use()
                } else {
                    ac = UIAlertController.alertOfTitle(NSLocalizedString("UseButton_\(self.id)", comment: ""), withMessage: NSLocalizedString("ConfirmAlertText", comment: ""), cancelButtonText: NSLocalizedString("Cancel", comment: ""), cancelStyle: .cancel, cancelAction: nil)
                    ac?.addActionButton(NSLocalizedString("CONFIRM", comment: ""), style: .destructive, handler: { action in
                        use()
                    })
                }
            } else {
                // OUT TIME
                if nowTime.compare(availableTime) == .orderedAscending {
                    ac = UIAlertController.alertOfTitle(NSLocalizedString("NotAvailableTitle", comment: ""), withMessage: NSLocalizedString("NotAvailableMessage", comment: ""), cancelButtonText: NSLocalizedString("NotAvailableButtonOk", comment: ""), cancelStyle: .destructive, cancelAction: nil)
                    feedbackType = .notificationFeedbackError
                }
                if nowTime.compare(expireTime) == .orderedDescending || self.used > 0 {
                    ac = UIAlertController.alertOfTitle(NSLocalizedString("ExpiredTitle", comment: ""), withMessage: NSLocalizedString("ExpiredMessage", comment: ""), cancelButtonText: NSLocalizedString("ExpiredButtonOk", comment: ""), cancelStyle: .destructive, cancelAction: nil)
                    feedbackType = .notificationFeedbackError
                }
            }
        }
        // only out time or need confirm will display alert controller
        let triggerFeedback = {
            if feedbackType != nil {
                UIImpactFeedback.triggerFeedback(feedbackType!)
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
