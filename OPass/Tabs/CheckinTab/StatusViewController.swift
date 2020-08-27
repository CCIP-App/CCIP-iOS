//
//  StatusViewController.swift
//  OPass
//
//  Created by FrankWu on 2019/6/17.
//  2019 OPass.
//

import UIKit
import AudioToolbox
import FontAwesome_swift

protocol StatusViewDelegate: class {
    func statusViewDisappear()
}

class StatusViewController: UIViewController {
    public var scenario: Scenario?
    public var delegate: StatusViewDelegate?

    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var attributesLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var noticeTextLabel: UILabel!
    @IBOutlet weak var scenarioTitle: UILabel!
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

        self.scenarioTitle.text = self.scenario?.DisplayText ?? ""
        self.noticeTextLabel.text = NSLocalizedString("StatusNotice", comment: "")

        if let attr = self.scenario?.Attributes {
            if attr._data.dictionaryValue.count > 0 {
                if let attrData = try? attr._data.rawData(options: .prettyPrinted) {
                    let jsonText = String(data: attrData, encoding: .utf8) ?? ""

                    // MarkDown view
                    let markdownStyleString = "<style>html, body {height: 100%; width: 100%;} body {display: flex; align-items: center; padding: 0; font-size: 24px;} pre {width: 100%;}</style>\n```\n\(jsonText)\n```"
                    self.downView = MarkdownView.init(markdownStyleString, toView: self.attributesLabel)
                    self.downView?.downView?.isOpaque = false
                }
                self.attributesLabel.isUserInteractionEnabled = true
            } else {
                self.attributesLabel.text = ""
            }
        }
        self.needCountdown = (self.scenario?.Countdown ?? 0) > 0
        self.countdownLabel.isHidden = !self.needCountdown
        self.countDownEnd = false
        self.countTime = Date()
        let used = self.scenario?.Used ?? 0
        let countdown = self.scenario?.Countdown ?? 0
        let counttime = Int(self.countTime?.timeIntervalSince1970 ?? 0)
        self.maxValue = Float(used + countdown - counttime)

        self.interval = Date().timeIntervalSince(self.countTime ?? Date.init())
        self.countDown = (self.maxValue - Float(self.interval))
        self.formatter = DateFormatter()
        self.formatter?.dateFormat = "yyyy/MM/dd HH:mm:ss"
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
        self.interval = now.timeIntervalSince(self.countTime ?? Date.init())

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
