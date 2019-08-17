//
//  StatusViewController.swift
//  OPass
//
//  Created by FrankWu on 2019/6/17.
//  Copyright © 2019 OPass. All rights reserved.
//

import UIKit
import AudioToolbox
import FontAwesome_swift

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
    @IBOutlet weak var closeButton: UIButton!

    private var downView: MarkdownView?

    private var isRelayout = false
    private var timer: Timer?
    private var countTime: Date?
    private var maxValue: Float = 0
    private var countDown: Float = 0
    private var interval: TimeInterval = 0.0
    private var formatter: DateFormatter?
    private var countDownEnd = false
    private var needCountdown = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Constants.SendFib("StatusViewController")
        view.autoresizingMask = []
        self.attributesLabel.text = ""

        // close button x FontAwesome Icon
        self.closeButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
        self.closeButton.setTitle("times", for: .normal)
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
            let jsonText = String(data: attrData, encoding: .utf8) ?? ""

            // MarkDown view
            let markdownStyleString = "<style>html, body {height: 100%; width: 100%;} body {display: flex; align-items: center; padding: 0; font-size: 20px;} pre {width: 100%;}</style>\n```\n\(jsonText)\n```"
            self.downView = MarkdownView.init(markdownStyleString, toView: self.attributesLabel)
            self.downView?.downView.isOpaque = false
            self.attributesLabel.isUserInteractionEnabled = true
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

    @IBAction func dismissStatus() {
        self.delegate?.statusViewDisappear()
        self.dismiss(animated: true)
    }
}
