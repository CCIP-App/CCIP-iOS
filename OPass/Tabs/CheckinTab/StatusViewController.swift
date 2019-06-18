//
//  StatusViewController.swift
//  OPass
//
//  Created by FrankWu on 2019/6/17.
//  Copyright © 2019 OPass. All rights reserved.
//

import UIKit
import AudioToolbox

class StatusViewController: UIViewController {
    var scenario: Scenario?

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
    private var maxValue: Int = 0
    private var countDown: Int = 0
    private var interval: TimeInterval = 0.0
    private var formatter: DateFormatter?
    private var countDownEnd = false
    private var needCountdown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // SEND_FIB("StatusViewController")
        view.autoresizingMask = []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isKit = (scenario?.Id == "kit") || (scenario?.Id == "vipkit")
        let dietType = scenario?.Attributes["diet"] as? String
        statusMessageLabel.text = isKit ? NSLocalizedString("StatusNotice", comment: "") : NSLocalizedString(dietType ?? "" + ("Lunch"), comment: "")
        noticeTextLabel.text = ""
        if !isKit {
            noticeTextLabel.text = NSLocalizedString("UseNoticeText", comment: "")
            statusMessageLabel.font = UIFont.systemFont(ofSize: 48.0)
            kitTitle.text = ""
            if (dietType == "meat") {
                statusMessageLabel.textColor = UIColor.colorFromHtmlColor("#f8e71c")
                visualEffectView.effect = UIBlurEffect(style: .dark)
                noticeTextLabel.textColor = UIColor.white
                nowTimeLabel.textColor = UIColor.white
            }
            if (dietType == "vegetarian") {
                statusMessageLabel.textColor = UIColor.colorFromHtmlColor("#4a90e2")
                visualEffectView.effect = UIBlurEffect(style: .light)
                noticeTextLabel.textColor = UIColor.black
                nowTimeLabel.textColor = UIColor.black
            }
        } else {
//            let displayText = scenario["display_text"] as? [AnyHashable : Any]
//            let lang = AppDelegate.longLangUI()
//            kitTitle.text = displayText?[lang] as? String
            kitTitle.text = scenario?.DisplayText
        }
        let attr = scenario?.Attributes
        if attr?._data.arrayObject?.count ?? 0 > 0 {
            var error: Error?
            var attrData: Data? = nil
            do {
                if let attr = attr {
                    attrData = try JSONSerialization.data(withJSONObject: attr, options: .prettyPrinted)
                }
            } catch {
            }
            var attrText: String? = nil
            if let attrData = attrData {
                attrText = String(data: attrData, encoding: .utf8)
            }
            attributesLabel.text = attrText
        } else {
            attributesLabel.text = ""
        }
        self.needCountdown = ((scenario?.Countdown) ?? 0 > 0)
        countdownLabel.isHidden = !needCountdown
        self.countDownEnd = false
        self.countTime = Date()
        maxValue = scenario!.Used! + scenario!.Countdown! - Int(self.countTime!.timeIntervalSince1970)
        
        self.interval = Date().timeIntervalSince(countTime!)
        self.countDown = (maxValue - Int(interval))
        self.formatter = DateFormatter()
        formatter!.dateFormat = "yyyy/MM/dd HH:mm:ss"
        countdownLabel.text = ""
        nowTimeLabel.text = ""
        view.isHidden = !needCountdown
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if isRelayout != true {
            let mnvc = presentingViewController as? MainNavViewController
            let cvc = mnvc?.children.first as? CheckinViewController
            let topStart = cvc?.controllerTopStart
            view.frame = CGRect(x: 0.0, y: -1.0 * (topStart ?? 0.0), width: view.frame.size.width, height: view.frame.size.height + (topStart ?? 0.0))
            isRelayout = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCountDown()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissStatus()
    }
    
    func setScenario(_ scenario: Scenario) {
        self.scenario = scenario
    }
    
    func startCountDown() {
        self.countTime = Date()
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(StatusViewController.updateCountDown), userInfo: nil, repeats: true)
    }
    
    @objc func updateCountDown() {
        var color = view.tintColor
        let now = Date()
        self.interval = now.timeIntervalSince(self.countTime!)
        
        self.countDown = (maxValue - Int(interval))
        if countDown <= 0 {
            self.countDown = 0
            color = UIColor.red
            if countDownEnd == false {
                ((next as? UIViewController)?.navigationItem.leftBarButtonItem)?.isEnabled = true
                timer?.invalidate()
                timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(StatusViewController.updateCountDown), userInfo: nil, repeats: true)
                self.countDownEnd = true
                
                if needCountdown {
                    let delaySec = Int(0.5)
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Double(delaySec) * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Double(delaySec) * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Double(delaySec) * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
                                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Double(delaySec) * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
                                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Double(delaySec) * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
                                        self.dismissStatus()
                                    })
                                })
                            })
                        })
                    })
                }else {
                    self.dismissStatus()
                }
            } else if countDown >= (maxValue / 2) {
                let at_ = 1 - ((countDown - (maxValue / 2)) / (maxValue - (maxValue / 2)))
                color = UIColor.colorFrom(view.tintColor, to: UIColor.purple, at: Double(at_))
            } else if countDown >= (maxValue / 6) {
                let at_ = 1 - ((countDown - (maxValue / 6)) / (maxValue - ((maxValue / 2) + (maxValue / 6))))
                color = UIColor.colorFrom(UIColor.purple, to: UIColor.orange, at: Double(at_))
            } else if countDown > 0 {
                let at_ = 1 - ((countDown - 0) / (maxValue - (maxValue - (maxValue / 6))))
                color = UIColor.colorFrom(UIColor.orange, to: UIColor.red, at: Double(at_))
            }
            countdownLabel.textColor = color
            countdownLabel.text = String(format: "%0.3f", countDown)
            nowTimeLabel.text = formatter?.string(from: now)
        }
    }
    
    func dismissStatus() {
        if needCountdown {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(5 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
                self.dismiss(animated: true)
            })
        } else {
            dismiss(animated: false)
        }
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
