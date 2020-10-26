//
//  GuideViewController.swift
//  OPass
//
//  Created by FrankWu on 2019/6/17.
//  2019 OPass.
//

import Foundation
import UIKit
import AFNetworking
import UICKeyChainStore
import ScanditBarcodeScanner

class GuideViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SBSScanDelegate, SBSProcessFrameDelegate {
    @IBOutlet weak var guideMessageLabel: UILabel!
    @IBOutlet weak var guideLineLabel: UILabel!
    @IBOutlet weak var redeemCodeText: UITextField!
    @IBOutlet weak var redeemButton: UIButton!

    private var isRelayout = false
    private var changePoint = CGPoint.zero

    private var scanditBarcodePicker: SBSBarcodePicker?
    private var qrButtonItem: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guideMessageLabel.text = NSLocalizedString("GuideViewMessage", comment: "")

        redeemCodeText.textColor = Constants.appConfigColor.RedeemCodeTextColor

        redeemButton.setTitle(NSLocalizedString("GuideViewButton", comment: ""), for: .normal)
        redeemButton.tintColor = .white
        redeemButton.backgroundColor = UIColor(red: 61 / 255.0, green: 152 / 255.0, blue: 60 / 255.0, alpha: 1)
        redeemButton.layer.cornerRadius = 7

        // Set carousel background linear diagonal gradient
        //   Create the colors
        let topColor: UIColor = Constants.appConfigColor.RedeemButtonLeftColor
        let bottomColor: UIColor = Constants.appConfigColor.RedeemButtonRightColor
        //   Create the gradient
        let theViewGradient = CAGradientLayer()
        theViewGradient.colors = [topColor.cgColor, bottomColor.cgColor]
        theViewGradient.frame = CGRect(x: 0, y: 0, width: redeemButton.frame.size.width, height: redeemButton.frame.size.height)
        theViewGradient.startPoint = CGPoint(x: 1, y: 0.5)
        theViewGradient.endPoint = CGPoint(x: 0, y: 0.2)
        theViewGradient.cornerRadius = 7
        //   Add gradient to view
        redeemButton.layer.insertSublayer(theViewGradient, at: 0)

        NotificationCenter.default.addObserver(self, selector: #selector(GuideViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GuideViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GuideViewController.appplicationDidEnterBackground(_:)), name: UIApplication.willResignActiveNotification, object: nil)

        Constants.SendFib("GuideViewController")

        view.autoresizingMask = []
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.handleQRButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.closeBarcodePickerOverlay()
    }

    @objc func appplicationDidEnterBackground(_ notification: Notification?) {
        self.dismiss(animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.redeemCode(nil)
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.phase == .began {
                self.redeemCodeText.resignFirstResponder()
            }
        }
    }

    @objc func keyboardWillShow(_ note: Notification?) {
        if self.changePoint.y != 0 {
            return
        }
        if view.frame.size.height <= 480 {
            self.changePoint.y = -30
        } else if view.frame.size.height <= 768 {
            self.changePoint.y = -165
        }
        self.moveOjectsByOffset(self.changePoint.y)
    }

    @objc func keyboardWillHide(_ note: Notification?) {
        self.moveOjectsByOffset(self.changePoint.y * -1)
        self.changePoint.y = 0
    }

    func moveOjectsByOffset(_ dy: CGFloat) {
        var guideMessageLabelFrame = self.guideMessageLabel.frame
        guideMessageLabelFrame.origin.y += dy
        self.guideMessageLabel.frame = guideMessageLabelFrame

        var guideLineLabelFrame = self.guideLineLabel.frame
        guideLineLabelFrame.origin.y += dy
        self.guideLineLabel.frame = guideLineLabelFrame

        var redeemCodeTextFrame = self.redeemCodeText.frame
        redeemCodeTextFrame.origin.y += dy
        self.redeemCodeText.frame = redeemCodeTextFrame

        var redeemButtonFrame = self.redeemButton.frame
        redeemButtonFrame.origin.y += dy
        self.redeemButton.frame = redeemButtonFrame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func redeemCode(_ sender: Any?) {
        var alreadyAlert = false
        self.redeemButton.isEnabled = false
        OPassAPI.RedeemCode(forEvent: "", withToken: redeemCodeText.text ?? "") { success, _, _ in
            if success {
                self.dismiss(animated: true)
            } else {
                if !alreadyAlert {
                    alreadyAlert = true
                    self.showAlert()
                }
            }
            self.redeemButton.isEnabled = true
        }
    }

    func showAlert() {
        let ac = UIAlertController.alertOfTitle(NSLocalizedString("GuideViewTokenErrorTitle", comment: ""), withMessage: NSLocalizedString("GuideViewTokenErrorDesc", comment: ""), cancelButtonText: NSLocalizedString("GotIt", comment: ""), cancelStyle: .cancel, cancelAction: nil)
        ac.showAlert({
            UIImpactFeedback.triggerFeedback(.notificationFeedbackError)
        })
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            AppDelegate.delegateInstance.displayGreetingsForLogin()
                        }
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
        }
    }

    @objc func callBarcodePickerOverlay() {
        self.showBarcodePickerOverlay()
    }

    func showBarcodePickerOverlay() {
        if self.scanditBarcodePicker != nil {
            self.closeBarcodePickerOverlay()
        } else {
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
            self.view.addConstraint(NSLayoutConstraint.init(item: self.scanditBarcodePicker?.view as Any, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0))
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
            button.frame = CGRect(x: (torchButton?.frame.origin.x ?? 0) + (torchButton?.frame.width ?? 0) + 15, y: (torchButton?.frame.origin.y ?? 0), width: 80, height: (torchButton?.frame.height ?? 0))
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
}
