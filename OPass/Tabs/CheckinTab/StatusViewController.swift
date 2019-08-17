//
//  StatusViewController.swift
//  OPass
//
//  Created by FrankWu on 2019/6/17.
//  Copyright © 2019 OPass. All rights reserved.
//

import UIKit
import AudioToolbox

protocol StatusViewDelegate : class {
    func statusViewDisappear()
}

class StatusViewController: UIViewController {
    public var scenario: Scenario?
    public var delegate: StatusViewDelegate?

    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var statusMessageLabel: UILabel!
    @IBOutlet weak var attributesLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var noticeTextLabel: UILabel!
    @IBOutlet weak var kitTitle: UILabel!
    @IBOutlet weak var nowTimeLabel: UILabel!

    private var isRelayout = false
    private var timer: Timer?
    private var countTime: Date?
    private var maxValue: Float = 0
    private var countDown: Float = 0
    private var interval: TimeInterval = 0.0
    private var formatter: DateFormatter?
    private var countDownEnd = false
    private var needCountdown = false

    private var originY: CGFloat = 0.0
    private var startY: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Constants.SendFib("StatusViewController")
        view.autoresizingMask = []

        // Add pan event
        let pan = UIPanGestureRecognizer(
            target:self,
            action:#selector(self.pan(_:)))
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(pan)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isKit = [ "kit", "vipkit" ].contains(self.scenario!.Id)
        let dietType = self.scenario!.Attributes["diet"] as? String ?? ""
        self.statusMessageLabel.text = NSLocalizedString(isKit ? "StatusNotice" : "\(dietType)Lunch", comment: "")
        self.noticeTextLabel.text = ""
        if !isKit {
            self.noticeTextLabel.text = NSLocalizedString("UseNoticeText", comment: "")
            self.statusMessageLabel.font = UIFont.systemFont(ofSize: 48.0)
            self.kitTitle.text = ""
            if (dietType == "meat") {
                self.statusMessageLabel.textColor = UIColor.colorFromHtmlColor("#f8e71c")
                self.visualEffectView.effect = UIBlurEffect(style: .dark)
                self.noticeTextLabel.textColor = UIColor.white
                self.nowTimeLabel.textColor = UIColor.white
            }
            if (dietType == "vegetarian") {
                self.statusMessageLabel.textColor = UIColor.colorFromHtmlColor("#4a90e2")
                self.visualEffectView.effect = UIBlurEffect(style: .light)
                self.noticeTextLabel.textColor = UIColor.black
                self.nowTimeLabel.textColor = UIColor.black
            }
        } else {
            self.kitTitle.text = self.scenario!.DisplayText
        }
        let attr = self.scenario!.Attributes
        if attr._data.dictionaryValue.count > 0 {
            let attrData = try! attr._data.rawData(options: .prettyPrinted)
            self.attributesLabel.text = String(data: attrData, encoding: .utf8)
        } else {
            self.attributesLabel.text = ""
        }
        self.needCountdown = (self.scenario!.Countdown ?? 0) > 0
        self.countdownLabel.isHidden = !self.needCountdown
        self.countDownEnd = false
        self.countTime = Date()
        self.maxValue = Float(self.scenario!.Used! + self.scenario!.Countdown! - Int(self.countTime!.timeIntervalSince1970))

        self.interval = Date().timeIntervalSince(self.countTime!)
        self.countDown = (self.maxValue - Float(self.interval))
        self.formatter = DateFormatter()
        self.formatter!.dateFormat = "yyyy/MM/dd HH:mm:ss"
        self.countdownLabel.text = ""
        self.nowTimeLabel.text = ""
        self.view.isHidden = !self.needCountdown
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if self.isRelayout != true {
            let mnvc = self.presentingViewController as? MainNavViewController
            let cvc = mnvc?.children.first as? CheckinViewController
            let topStart = cvc?.controllerTopStart
            view.frame = CGRect(x: 0.0, y: -1.0 * (topStart ?? 0.0), width: self.view.frame.size.width, height: self.view.frame.size.height + (topStart ?? 0.0))
            self.isRelayout = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startCountDown()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismissStatus()
    }

    func setScenario(_ scenario: Scenario) {
        self.scenario = scenario
    }

    func startCountDown() {
        self.countTime = Date()
        self.timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(StatusViewController.updateCountDown), userInfo: nil, repeats: true)
    }

    @objc func updateCountDown() {
        var color = self.view.tintColor
        let now = Date()
        self.interval = now.timeIntervalSince(self.countTime!)

        self.countDown = (self.maxValue - Float(self.interval))
        if self.countDown <= 0 {
            self.countDown = 0
            color = .red
            if self.countDownEnd == false {
                ((self.next as? UIViewController)?.navigationItem.leftBarButtonItem)?.isEnabled = true
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(StatusViewController.updateCountDown), userInfo: nil, repeats: true)
                self.countDownEnd = true

                if self.needCountdown {
                    let delayMSec = DispatchTimeInterval.milliseconds(Int(500))
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayMSec) {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayMSec) {
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayMSec) {
                                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayMSec) {
                                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayMSec) {
                                        self.dismissStatus()
                                    }
                                }
                            }
                        }
                    }
                } else {
                    self.dismissStatus()
                }
            }
        } else if self.countDown >= (self.maxValue / 2) {
            let at_ = 1 - ((self.countDown - (self.maxValue / 2)) / (self.maxValue - (self.maxValue / 2)))
            color = UIColor.colorFrom(view.tintColor, to: .purple, at: Double(at_))
        } else if self.countDown >= (self.maxValue / 6) {
            let at_ = 1 - ((self.countDown - (self.maxValue / 6)) / (self.maxValue - ((self.maxValue / 2) + (self.maxValue / 6))))
            color = UIColor.colorFrom(.purple, to: .orange, at: Double(at_))
        } else if self.countDown > 0 {
            let at_ = 1 - ((self.countDown - 0) / (self.maxValue - (self.maxValue - (self.maxValue / 6))))
            color = UIColor.colorFrom(.orange, to: .red, at: Double(at_))
        }
        self.countdownLabel.textColor = color
        self.countdownLabel.text = String(format: "%0.3f", self.countDown)
        self.nowTimeLabel.text = self.formatter?.string(from: now)
    }

    func dismissStatus() {
        self.delegate?.statusViewDisappear()
        self.dismiss(animated: true)
    }

    @objc func pan(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self.view)
        switch sender.state {
        case .began:
            NSLog("began")
            originY = self.view.frame.origin.y
            startY = point.y
        case .ended:
            NSLog("ended")
            if ( self.view.frame.origin.y > self.view.frame.size.height / 4) {
                dismissStatus()
            } else {
                self.view.frame.origin = CGPoint(x: self.view.frame.origin.x, y: originY)
            }
        case .changed:
            let dY = startY - point.y
            NSLog("dY: " + dY.description)
            NSLog("x: " + point.x.description + " y: " + point.y.description)

            if (originY < self.view.frame.origin.y - dY) {
                UIView.animate(
                    withDuration: 0,
                    animations: {
                        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: -dY)
                    }
                )
            } else {
                self.view.frame.origin = CGPoint(x: self.view.frame.origin.x, y: originY)
            }
        default:
            NSLog("x: " + point.x.description + " y: " + point.y.description)
        }
    }
}
