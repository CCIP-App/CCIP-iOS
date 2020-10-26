//
//  CheckinViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/16.
//  2019 OPass.
//

import Foundation
import UIKit
import AudioToolbox
import MBProgressHUD
import iCarousel
import ScanditBarcodeScanner

@objc enum HideCheckinViewOverlay: Int {
    case Guide
    case Status
    case InvalidNetwork
}

@objc class CheckinViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, StatusViewDelegate, InvalidNetworkRetryDelegate, iCarouselDataSource, iCarouselDelegate, SBSScanDelegate, SBSProcessFrameDelegate {
    @objc public var controllerTopStart: CGFloat = 0

    @IBOutlet private var cards: iCarousel?
    @IBOutlet private var ivRectangle: UIImageView?
    @IBOutlet private var ivUserPhoto: UIImageView?
    @IBOutlet private var lbHi: UILabel?
    @IBOutlet private var lbUserName: UILabel?

    private var pageControl: UIPageControl = UIPageControl.init()

    private var scanditBarcodePicker: SBSBarcodePicker?
    private var qrButtonItem: UIBarButtonItem?

    private var guideViewController: GuideViewController?
    private var statusViewController: StatusViewController?
    private var invalidNetworkMsgViewController: InvalidNetworkMessageViewController?

    private var progress: MBProgressHUD?

    // MARK: - View Events

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage.init()
        self.navigationController?.navigationBar.backgroundColor = .clear

        AppDelegate.delegateInstance.checkinView = self

        // Init configure pageControl
        self.pageControl.numberOfPages = 0
        // Init configure carousel
        self.cards?.addSubview(self.pageControl)
        self.cards?.type = .rotary
        self.cards?.isPagingEnabled = true
        self.cards?.bounceDistance = 0.3
        self.cards?.contentOffset = CGSize(width: 0, height: -5)

        Constants.SendFib("CheckinViewController")

        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(navSingleTap))

        let isHidden = !Constants.haveAccessToken

        self.lbUserName?.text = " "
        self.lbUserName?.isUserInteractionEnabled = true
        self.lbUserName?.addGestureRecognizer(tapGesture)
        self.lbUserName?.isHidden = isHidden

        self.lbHi?.isHidden = isHidden

        self.ivUserPhoto?.image = Constants.AssertImage(name: "StaffIconDefault", InBundleName: "PassAssets")
        self.ivUserPhoto?.isHidden = isHidden
        self.ivUserPhoto?.layer.cornerRadius = (self.ivUserPhoto?.frame.size.height ?? 0) / 2
        self.ivUserPhoto?.layer.masksToBounds = true

        self.ivRectangle?.setGradientColor(from: Constants.appConfigColor.CheckinRectangleLeftColor, to: Constants.appConfigColor.CheckinRectangleRightColor, startPoint: CGPoint(x: -0.4, y: 0.5), toPoint: CGPoint(x: 1, y: 0.5))

        NotificationCenter.default.addObserver(self, selector: #selector(appplicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.controllerTopStart = (self.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0) + (self.navigationController?.navigationBar.frame.size.height ?? 0)
        self.handleQRButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadCard()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideView(.Guide, nil)
        self.hideView(.Status, nil)
        self.hideView(.InvalidNetwork, nil)
        self.closeBarcodePickerOverlay()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        OPassAPI.scenarios = []
        self.cards?.reloadData()
        self.lbUserName?.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func appplicationDidBecomeActive(_ notification: NSNotification) {
        self.reloadCard()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        switch destination.className {
        case GuideViewController.className:
            self.guideViewController = destination as? GuideViewController
        case StatusViewController.className:
            self.statusViewController = destination as? StatusViewController
            self.statusViewController?.scenario = sender as? Scenario
            self.statusViewController?.delegate = self
        case InvalidNetworkMessageViewController.className:
            if let inmvc = destination as? InvalidNetworkMessageViewController {
                inmvc.message = sender as? String ?? ""
                inmvc.delegate = self
            }
        default:
            break
        }
    }

    func refresh() {
        self.reloadCard()
    }

    // MARK: - Dev Mode

    @objc func navSingleTap() {
        struct tap {
            static var tapTimes: Int = 0
            static var oldTapTime: Date?
            static var newTapTime: Date?
        }
        //        NSLog("navSingleTap")

        tap.newTapTime = Date.init()
        if tap.oldTapTime == nil {
            tap.oldTapTime = tap.newTapTime
        }
        guard let oldTime = tap.oldTapTime else { return }

        if Constants.isDevMode {
            // NSLog("navSingleTap from MoreTab")
            if ((tap.newTapTime?.timeIntervalSince(oldTime)) ?? TimeInterval(0)) <= TimeInterval(0.25) {
                tap.tapTimes += 1
                if tap.tapTimes >= 10 {
                    NSLog("--  Success tap 10 times  --")
                    if Constants.haveAccessToken {
                        NSLog("-- Clearing the Token --")
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        Constants.accessToken = ""
                        AppDelegate.delegateInstance.checkinView?.reloadCard()
                    } else {
                        NSLog("-- Token is already clear --")
                    }
                    tap.tapTimes = 1
                }
            } else {
                NSLog("--  Failed, just tap \(tap.tapTimes) times  --")
                NSLog("-- Not trigger clean token --")
                tap.tapTimes = 1
            }
            tap.oldTapTime = tap.newTapTime
        }
    }

    // MARK: - hide custom view controller method

    func hideView(_ viewType: HideCheckinViewOverlay, _ completion: (() -> Void)?) {
        let visible = [
            HideCheckinViewOverlay.Guide: self.guideViewController?.isVisible,
            HideCheckinViewOverlay.Status: self.statusViewController?.isVisible,
            HideCheckinViewOverlay.InvalidNetwork: self.invalidNetworkMsgViewController?.isVisible
        ][viewType] ?? false
        let isVisible: Bool = visible ?? false

        let _completion = {
            if let c = completion { c() }
        }

        if isVisible {
            if let overlay = [
                HideCheckinViewOverlay.Guide: {
                    self.guideViewController?.dismiss(animated: true, completion: {
                        self.guideViewController = nil
                        _completion()
                    })
                },
                HideCheckinViewOverlay.Status: {
                    self.statusViewController?.dismiss(animated: true, completion: {
                        self.statusViewController = nil
                        _completion()
                    })
                },
                HideCheckinViewOverlay.InvalidNetwork: {
                    self.invalidNetworkMsgViewController?.dismiss(animated: true, completion: {
                        self.invalidNetworkMsgViewController = nil
                        _completion()
                    })
                }
                ][viewType] {
                overlay()
            }
        } else {
            _completion()
        }
    }

    // MARK: - cards methods

    func goToCard() {
        if Constants.haveAccessToken {
            let checkinCard = UserDefaults.standard.object(forKey: "CheckinCard") as? NSDictionary
            if checkinCard != nil {
                let key = checkinCard?.object(forKey: "key") as? String ?? ""
                for item in OPassAPI.scenarios {
                    if item.Id == key {
                        if let index = OPassAPI.scenarios.firstIndex(of: item) {
                            NSLog("index: \(index)")
                            self.cards?.scrollToItem(at: index, animated: true)
                        }
                    }
                }
                UserDefaults.standard.removeObject(forKey: "CheckinCard")
            } else {
                // force scroll to first selected item at first load
                if let cards = self.cards {
                    if cards.numberOfItems > 0 {
                        for scenario in OPassAPI.scenarios {
                            let used = scenario.Used != nil
                            let disabled = scenario.Disabled != nil
                            if !used && !disabled {
                                self.cards?.scrollToItem(at: OPassAPI.scenarios.firstIndex(of: scenario) ?? 0, animated: true)
                                break
                            }
                        }
                    }
                }
            }
            UserDefaults.standard.synchronize()
        }
        self.progress?.hide(animated: true)
    }

    func reloadAndGoToCard() {
        self.cards?.reloadData()
        self.goToCard()
    }

    func showGuide() {
        if self.scanditBarcodePicker == nil {
            if !(self.presentedViewController?.isKind(of: GuideViewController.self) ?? false) {
                self.performSegue(withIdentifier: "ShowGuide", sender: self.cards)
            }
            OPassAPI.scenarios.removeAll()
            self.reloadAndGoToCard()
        }
    }

    func processStatus() {
        OPassAPI.GetCurrentStatus { success, obj, _ in
            if success {
                self.hideView(.Guide, nil)
                if let userInfo = obj as? ScenarioStatus {
                    OPassAPI.userInfo = userInfo
                    OPassAPI.scenarios = OPassAPI.userInfo?.Scenarios ?? []

                    let isHidden = !Constants.haveAccessToken
                    self.lbHi?.isHidden = isHidden
                    self.ivUserPhoto?.isHidden = isHidden
                    self.lbUserName?.isHidden = isHidden
                    self.lbUserName?.text = OPassAPI.userInfo?.UserId
                    AppDelegate.sendTag("\(OPassAPI.userInfo?.EventId ?? "")\(OPassAPI.userInfo?.Role ?? "")", value: OPassAPI.userInfo?.Token ?? "")
                    if OPassAPI.isLoginSession {
                        AppDelegate.delegateInstance.displayGreetingsForLogin()
                    }
                    if ((OPassAPI.userInfo?.Role ?? "").count > 0) {
                        if let info = OPassAPI.userInfo {
                            self.cards?.isHidden = !((OPassAPI.eventInfo?.Features[OPassKnownFeatures.FastPass]?.VisibleRoles?.contains(info.Role)) ?? true)
                        }
                    }
                    OPassAPI.refreshTabBar()
                    OPassAPI.openFirstAvailableTab()
                    self.reloadAndGoToCard()
                }
            } else {
                func broken(_ msg: String = "Networking_Broken") {
                    self.performSegue(withIdentifier: "ShowInvalidNetworkMsg", sender: NSLocalizedString(msg, comment: ""))
                }
                guard let sr = obj as? OPassNonSuccessDataResponse else {
//                    broken()
                    return
                }
                switch (sr.Response?.statusCode) {
                    case 200:
                        broken("Data_Wrong")
                    case 400:
                        guard let responseObject = sr.Obj as? NSDictionary else { return }
                        let msg = responseObject.value(forKeyPath: "json.message") as? String ?? ""
                        if msg == "invalid token" {
                            NSLog("\(msg)")

                            Constants.accessToken = ""

                            let ac = UIAlertController.alertOfTitle(NSLocalizedString("InvalidTokenAlert", comment: ""), withMessage: NSLocalizedString("InvalidTokenDesc", comment: ""), cancelButtonText: NSLocalizedString("GotIt", comment: ""), cancelStyle: .cancel) { _ in
                                self.reloadCard()
                            }
                            ac.showAlert {
                                UIImpactFeedback.triggerFeedback(.notificationFeedbackError)
                            }
                        }
                    case 403:
                        broken("Networking_WrongWiFi")
                    default:
                        broken()
                }
            }
        }
    }

    @objc func reloadCard() {
        if self.progress != nil {
            self.progress?.hide(animated: true)
        }
        self.progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.progress?.mode = .indeterminate
        self.handleQRButton()

        let isHidden = !Constants.haveAccessToken
        self.lbHi?.isHidden = isHidden
        self.ivUserPhoto?.isHidden = isHidden
        self.lbUserName?.isHidden = isHidden
        self.lbUserName?.text = " "

        if !Constants.haveAccessToken {
            self.showGuide()
        } else {
            self.processStatus()
        }
    }

    // MARK: - display messages

    func showCountdown(_ scenario: Scenario) {
        self.lbHi?.isHidden = true
        self.lbUserName?.isHidden = true
        self.ivUserPhoto?.isHidden = true

        NSLog("Show Countdown: \(scenario)")
        self.performSegue(withIdentifier: "ShowCountdown", sender: scenario)
    }

    public func statusViewDisappear() {
        let isHidden = !Constants.haveAccessToken
        self.lbHi?.isHidden = isHidden
        self.ivUserPhoto?.isHidden = isHidden
        self.lbUserName?.isHidden = isHidden
    }

    @objc func showInvalidNetworkMsg(_ msg: String? = nil) {
        self.performSegue(withIdentifier: "ShowInvalidNetworkMsg", sender: msg)
    }

    // MARK: - QR Code Scanner

    func handleQRButton() {
        if self.qrButtonItem == nil {
            self.qrButtonItem = UIBarButtonItem.init(image: Constants.AssertImage(name: "QR_Code", InBundleName: "AssetsUI"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(callBarcodePickerOverlay))
        }
        self.navigationItem.rightBarButtonItem = nil
        if Constants.isDevMode || !Constants.haveAccessToken {
            self.navigationItem.rightBarButtonItem = self.qrButtonItem
        }
    }

    func hideQRButton() {
        if !Constants.isDevMode {
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    public func barcodePicker(_ barcodePicker: SBSBarcodePicker, didProcessFrame frame: CMSampleBuffer, session: SBSScanSession) {
        //
    }

    //! [SBSBarcodePicker overlayed as a view]

    /**
     * A simple example of how the barcode picker can be used in a simple view of various dimensions
     * and how it can be added to any o ther view. This example scales the view instead of cropping it.
     */
    public func barcodePicker(_ picker: SBSBarcodePicker, didScan session: SBSScanSession) {
        session.pauseScanning()

        let recognized = session.newlyRecognizedCodes
        if let code = recognized.first {
            // Add your own code to handle the barcode result e.g.
            NSLog("scanned \(code.symbologyName) barcode: \(String(describing: code.data))")

            OperationQueue.main.addOperation {
                OPassAPI.RedeemCode(forEvent: "", withToken: code.data ?? "") { (success, obj, _) in
                    if success {
                        self.perform(#selector(self.reloadCard), with: nil, afterDelay: 0.5)
                        self.perform(#selector(self.closeBarcodePickerOverlay), with: nil, afterDelay: 0.5)
                    } else {
                        func broken(_ msg: String = "") {
                            let ac = UIAlertController.alertOfTitle(NSLocalizedString("GuideViewTokenErrorTitle", comment: ""), withMessage: NSLocalizedString("GuideViewTokenErrorDesc", comment: ""), cancelButtonText: NSLocalizedString("GotIt", comment: ""), cancelStyle: .cancel) { _ in
                                self.scanditBarcodePicker?.resumeScanning()
                            }
                            ac.showAlert {
                                UIImpactFeedback.triggerFeedback(.notificationFeedbackError)
                            }
                        }
                        guard let sr = obj as? OPassNonSuccessDataResponse else {
                            return
                        }
                        switch (sr.Response?.statusCode) {
                        case 400:
                            guard let responseObject = sr.Obj as? NSDictionary else { return }
                            let msg = responseObject.value(forKeyPath: "json.message") as? String ?? ""
                            if msg == "invalid token" {
                                NSLog("\(msg)")
                                broken()
                            }
                        case 403:
                            broken("Networking_WrongWiFi")
                        default:
                            return
                        }
                    }
                }
            }
        }
    }

    @objc func closeBarcodePickerOverlay() {
        if self.scanditBarcodePicker != nil {
            self.qrButtonItem?.image = Constants.AssertImage(name: "QR_Code", InBundleName: "AssetsUI")
            self.scanditBarcodePicker?.removeFromParent()
            self.scanditBarcodePicker?.view.removeFromSuperview()
            self.scanditBarcodePicker?.didMove(toParent: nil)
            self.scanditBarcodePicker = nil
            let isHidden = !Constants.haveAccessToken
            self.lbHi?.isHidden = isHidden
            self.lbUserName?.isHidden = isHidden
            self.ivUserPhoto?.isHidden = isHidden
        }
    }

    @objc func callBarcodePickerOverlay() {
        self.hideView(.Guide) {
            self.showBarcodePickerOverlay()
        }
    }

    func showBarcodePickerOverlay() {
        if self.scanditBarcodePicker != nil {
            self.closeBarcodePickerOverlay()

            if !Constants.haveAccessToken {
                self.performSegue(withIdentifier: "ShowGuide", sender: nil)
            } else {
                self.hideQRButton()
            }
        } else {
            self.lbHi?.isHidden = true
            self.ivUserPhoto?.isHidden = true
            self.qrButtonItem?.image = Constants.AssertImage(name: "QR_Code_Filled", InBundleName: "AssetsUI")
            // Configure the barcode picker through a scan settings instance by defining which
            // symbologies should be enabled.
            let scanSettings = SBSScanSettings.default()
            // prefer backward facing camera over front-facing cameras.
            scanSettings.cameraFacingPreference = .back
            // Enable symbologies that you want to scan
            scanSettings.setSymbology(.qr, enabled: true)

            self.scanditBarcodePicker = SBSBarcodePicker.init(settings: scanSettings)
            /* Set the delegate to receive callbacks.
             * This is commented out here in the demo app since the result view with the scan results
             * is not suitable for this overlay view */
            self.scanditBarcodePicker?.scanDelegate = self
            self.scanditBarcodePicker?.processFrameDelegate = self

            // Add a button behind the subview to close it.
            // self.backgroundButton.hidden = NO;

            if let picker = self.scanditBarcodePicker {
                self.addChild(picker)
                self.view.addSubview(picker.view)
                self.scanditBarcodePicker?.didMove(toParent: self)
            }

            self.scanditBarcodePicker?.view.translatesAutoresizingMaskIntoConstraints = false

            // Add constraints to scale the view and place it in the center of the controller.
            self.view.addConstraint(NSLayoutConstraint.init(item: self.scanditBarcodePicker?.view as Any, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
            self.view.addConstraint(NSLayoutConstraint.init(item: self.scanditBarcodePicker?.view as Any, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: self.controllerTopStart))
            // Add constraints to set the width to 200 and height to 400. Since this is not the aspect ratio
            // of the camera preview some of the camera preview will be cut away on the left and right.
            self.view.addConstraint(NSLayoutConstraint.init(item: self.scanditBarcodePicker?.view as Any, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0))
            self.view.addConstraint(NSLayoutConstraint.init(item: self.scanditBarcodePicker?.view as Any, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -(self.tabBarController?.tabBar.frame.size.height ?? 0)))

            // add "OpenQRCodeFromFile" button
            let barcodePickerOverlay = self.scanditBarcodePicker?.overlayController.view
            let torchButton = barcodePickerOverlay?.subviews[2]
            let button = UIButton.init(type: .roundedRect)
            button.layer.masksToBounds = false
            button.layer.cornerRadius = (torchButton?.frame.height ?? 2) / 2
            button.frame = CGRect(x: (torchButton?.frame.origin.x ?? 0) + (torchButton?.frame.width ?? 0) + 15, y: (torchButton?.frame.origin.y ?? 0) + (self.navigationController?.navigationBar.frame.height ?? 0), width: 80, height: (torchButton?.frame.height ?? 0))
            button.backgroundColor = UIColor.white.withAlphaComponent(0.35)
            button.setTitle(NSLocalizedString("OpenQRCodeFromFile", comment: ""), for: .normal)
            button.tintColor = .black
            button.addTarget(self, action: #selector(getImageFromLibrary), for: .touchUpInside)
            barcodePickerOverlay?.addSubview(button)

            self.scanditBarcodePicker?.startScanning(inPausedState: true, completionHandler: {
                self.scanditBarcodePicker?.perform(#selector(SBSBarcodePicker.startScanning as (SBSBarcodePicker) -> () -> Void), with: nil, afterDelay: 0.5)
            })
        }
    }

    // MARK: - QR Code from Camera Roll Library

    @objc func getImageFromLibrary() {
        let imagePicker = UIImagePickerController.init()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let mediaType = info[.mediaType] as? String ?? ""

        if mediaType == "public.image" {
            guard let srcImage = info[.originalImage] as? UIImage else { return }
            guard let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) else { return }

            guard let cgImage = srcImage.cgImage else { return }
            let image = CIImage.init(cgImage: cgImage)
            guard let features = detector.features(in: image) as? [CIQRCodeFeature] else { return }

            var ac: UIAlertController? = nil
            var noQR = false
            if (features.count == 0) {
                NSLog("no QR in the image")
                noQR = true
            } else {
                for feature in features {
                    NSLog("feature: \(String(describing: feature.messageString))")
                }
                guard let feature = features.first else { return }
                let result = feature.messageString
                NSLog("QR: \(String(describing: result))")

                if result == nil {
                    noQR = true
                } else {
                    OPassAPI.RedeemCode(forEvent: "", withToken: result ?? "") { (success, _, _) in
                        if success {
                            picker.dismiss(animated: true) {
                                // self.reloadCard()
                            }
                        } else {
                            ac = UIAlertController.alertOfTitle(NSLocalizedString("GuideViewTokenErrorTitle", comment: ""), withMessage: NSLocalizedString("GuideViewTokenErrorDesc", comment: ""), cancelButtonText: NSLocalizedString("GotIt", comment: ""), cancelStyle: .cancel, cancelAction: nil)
                            ac?.showAlert {
                                UIImpactFeedback.triggerFeedback(.notificationFeedbackError)
                            }
                        }
                    }
                }
            }

            if (noQR) {
                ac = UIAlertController.alertOfTitle(NSLocalizedString("QRFileNotAvailableTitle", comment: ""), withMessage: NSLocalizedString("QRFileNotAvailableDesc", comment: ""), cancelButtonText: NSLocalizedString("GotIt", comment: ""), cancelStyle: .cancel, cancelAction: nil)
                ac?.showAlert {
                    UIImpactFeedback.triggerFeedback(.notificationFeedbackError)
                }
            }
        }
    }

    // MARK: - iCarousel methods

    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        if OPassAPI.scenarios.count > 0 {
            self.pageControl.currentPage = carousel.currentItemIndex
        }
    }

    func numberOfItems(in carousel: iCarousel) -> Int {
        let count = OPassAPI.scenarios.count
        self.pageControl.numberOfPages = count
        return count
    }

    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        struct card {
            static var cardRect = CGRect()
        }
        var view = view
        // Init configure pageControl
        self.pageControl.isHidden = true  // set page control to hidden
        if card.cardRect.isEmpty {
            let pageControlFrame = self.pageControl.frame
            self.pageControl.frame = CGRect(x: self.view.frame.size.width / 2, y: ((self.cards?.frame.size.height ?? 0) + (self.cards?.frame.size.height ?? 0) - (self.pageControl.isHidden ? 0 : 10)) / 2, width: pageControlFrame.size.width, height: pageControlFrame.size.height)
            // Init cardRect
            // x 0, y 0, left 30, up 40, right 30, bottom 50
            // self.cards.contentOffset = CGSizeMake(0, -5.0f); // set in viewDidLoad
            // 414 736
            card.cardRect = CGRect(x: 0, y: 0, width: (self.cards?.bounds.size.width ?? 0), height: (self.cards?.frame.size.height ?? 0) - (self.pageControl.isHidden ? 0 : 10))
        }

        // create new view if no view is available for recycling
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let haveScenario = OPassAPI.scenarios.count > 0
        if haveScenario {
            guard let temp = storyboard.instantiateViewController(withIdentifier: "CheckinCardReuseView") as? CheckinCardViewController else { return UIView.init() }
            temp.view.frame = card.cardRect
            view = temp.view

            let scenario = OPassAPI.scenarios[index]

            let id = scenario.Id
            let isCheckin = id.contains("checkin")
            let isLunch = id.contains("lunch")
            let isKit = id.lowercased().contains("kit")
            let isVipKit = id.lowercased().contains("vipkit")
            let isShirt = id.lowercased().contains("shirt")
            let isRadio = id.contains("radio")
            let isDisabled = scenario.Disabled != nil
            let isUsed = scenario.Used != nil
            temp.setId(id)

            let dateRange = OPassAPI.ParseScenarioRange(scenario)
            let availableRange = "\(dateRange.first ?? "")\n\(dateRange.last ?? "")"
            let dd = OPassAPI.ParseScenarioType(id)
            let did = dd["did"]
            let scenarioType = dd["scenarioType"]
            let defaultIcon = Constants.AssertImage(name: "doc", InBundleName: "PassAssets")
            let scenarioIcon = Constants.AssertImage(name: (scenarioType as? String) ?? "", InBundleName: "PassAssets") ?? defaultIcon
            temp.checkinTitle.textColor = Constants.appConfigColor.CardTextColor
            temp.checkinTitle.text = scenario.DisplayText
            temp.checkinDate.textColor = Constants.appConfigColor.CardTextColor
            temp.checkinDate.text = availableRange
            temp.checkinText.textColor = Constants.appConfigColor.CardTextColor
            temp.checkinText.text = NSLocalizedString("CheckinNotice", comment: "")
            temp.checkinIcon.image = scenarioIcon

            if isCheckin {
                if let day = did {
                    temp.checkinIcon.image = Constants.AssertImage(name: "day\(day)", InBundleName: "PassAssets")
                    temp.checkinText.text = NSLocalizedString("CheckinText", comment: "")
                }
            }
            if isLunch {
                // nothing to do
            }
            if isKit {
                // nothing to do
            }
            if isVipKit {
                temp.checkinText.text = NSLocalizedString("CheckinTextVipKit", comment: "")
            }
            if isShirt {
                temp.checkinText.text = NSLocalizedString("CheckinStaffShirtNotice", comment: "")
            }
            if isRadio {
                temp.checkinText.text = NSLocalizedString("CheckinStaffRadioNotice", comment: "")
            }
            if isDisabled {
                temp.setDisabled(scenario.Disabled)
                temp.checkinBtn.setTitle("\(scenario.Disabled ?? "")", for: .normal)
                temp.checkinBtn.setGradientColor(from: Constants.appConfigColor.DisabledButtonLeftColor, to: Constants.appConfigColor.DisabledButtonRightColor, startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
            } else if isUsed {
                temp.setUsed(scenario.Used)
                if isCheckin {
                    temp.checkinBtn.setTitle(NSLocalizedString("CheckinViewButtonPressed", comment: ""), for: .normal)
                } else {
                    temp.checkinBtn.setTitle(NSLocalizedString("UseButtonPressed", comment: ""), for: .normal)
                }
                temp.checkinBtn.setGradientColor(from: Constants.appConfigColor.UsedButtonLeftColor, to: Constants.appConfigColor.UsedButtonRightColor, startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
            } else {
                temp.setUsed(nil)
                if isCheckin {
                    temp.checkinBtn.setTitle(NSLocalizedString("CheckinViewButton", comment: ""), for: .normal)
                } else {
                    temp.checkinBtn.setTitle(NSLocalizedString("UseButton", comment: ""), for: .normal)
                }
                temp.checkinBtn.setGradientColor(from: Constants.appConfigColor.CheckinButtonLeftColor, to: Constants.appConfigColor.CheckinButtonRightColor, startPoint: CGPoint(x: 0.2, y: 0.8), toPoint: CGPoint(x: 1, y: 0.5))
            }
            temp.checkinBtn.tintColor = .white

            temp.setDelegate(self)
            temp.setScenario(scenario)
        }

        return view ?? UIView.init()
    }

    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch (option) {
        case .wrap:
            //normally you would hard-code this to YES or NO
            return 0
        case .spacing:
            //add a bit of spacing between the item views
            return value * 0.9
        case .fadeMax:
            return 0
        case .fadeMin:
            return 0
        case .fadeMinAlpha:
            return 0.65
        case .arc:
            return value * (CGFloat(carousel.numberOfItems) / 48)
        case .radius:
            return value
        case .showBackfaces, .angle, .tilt, .count, .fadeRange, .offsetMultiplier, .visibleItems:
            return value
        default:
            return value
        }
    }
}
