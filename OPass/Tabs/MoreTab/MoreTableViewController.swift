//
//  MoreTableViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/2/9.
//  2019 OPass.
//

import Foundation
import UIKit
import SwiftUI
import AudioToolbox
import AFNetworking
import FontAwesome_swift
import Nuke

let ACKNOWLEDGEMENTS = "Acknowledgements"
let INTERNAL_CONFIG = "InternalConfig"

class MoreTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var moreTableView: UITableView?
    var shimmeringLogoView: FBShimmeringView = FBShimmeringView.init(frame: CGRect(x: 0, y: 0, width: 500, height: 50))
    var userInfo: ScenarioStatus?
    var moreItems: NSArray?
    var switchEventButton: UIBarButtonItem?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        guard let cell = sender as? UITableViewCell else { return }
        let title = cell.textLabel?.text
        Constants.SendFib("MoreTableView", WithEvents: [ "MoreTitle": title ])
        destination.title = title
        cell.setSelected(false, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // set logo on nav title
        self.shimmeringLogoView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(navSingleTap))
        tapGesture.numberOfTapsRequired = 1
        self.shimmeringLogoView.addGestureRecognizer(tapGesture)
        self.navigationItem.titleView = self.shimmeringLogoView

        guard let navController = self.navigationController else { return }
        let nvBar = navController.navigationBar
        nvBar.setBackgroundImage(UIImage.init(), for: .default)
        nvBar.shadowImage = UIImage.init()
        nvBar.backgroundColor = UIColor.clear
        nvBar.isTranslucent = false
        let frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: (self.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0) + navController.navigationBar.frame.size.height)
        let headView = UIView.init(frame: frame)
        headView.setGradientColor(from: Constants.appConfigColor.MoreTitleLeftColor, to: Constants.appConfigColor.MoreTitleRightColor, startPoint: CGPoint(x: -0.4, y: 0.5), toPoint: CGPoint(x: 1, y: 0.5))
        let naviBackImg = headView.layer.sublayers?.last?.toImage()
        nvBar.setBackgroundImage(naviBackImg, for: .default)

        Constants.SendFib("MoreTableViewController")

        if self.switchEventButton == nil {
            let attribute = [
                NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 20, style: .solid)
            ]
            self.switchEventButton = UIBarButtonItem.init(title: "", style: .plain, target: self, action: #selector(CallSwitchEventView))
            self.switchEventButton?.setTitleTextAttributes(attribute, for: .normal)
            self.switchEventButton?.title = String.fontAwesomeIcon(code: "fa-sign-out-alt")
        }

        self.navigationItem.rightBarButtonItem = self.switchEventButton

        let emptyButton = UIBarButtonItem.init(title: "　", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = emptyButton;
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Constants.LoadDevLogoTo(view: self.shimmeringLogoView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if Constants.haveAccessToken {
            checkNickName()
        }

        let features = OPassAPI.eventInfo?.Features.map { feature -> [Any?] in
            switch OPassKnownFeatures(rawValue: feature.Feature) {
            case Optional(.Puzzle):
                return ["Puzzle", feature]
            case Optional(.Ticket):
                return ["Ticket", feature]
            case Optional(.Telegram):
                return ["Telegram", feature]
            case Optional(.WiFiConnect):
                return ["WiFiConnect", feature]
            case Optional(.Venue):
                return ["VenueWeb", feature]
            case Optional(.Staffs):
                return ["StaffsWeb", feature]
            case Optional(.Sponsors):
                return ["SponsorsWeb", feature]
            case Optional(.Partners):
                return ["PartnersWeb", feature]
            case Optional(.WebView):
                return ["MoreWeb", feature]
            default:
                return ["", nil]
            }
        }
        self.moreItems = ((features ?? [["", nil]]) + [
            [ACKNOWLEDGEMENTS, nil]
        ] + (
            Constants.isDevMode ? [[INTERNAL_CONFIG, nil]] : []
        )).filter {
            guard let v = $0[0] else { return false }
            guard let s = v as? String else { return false }
            return s.count > 0
        } as NSArray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func CallSwitchEventView() {
        // clear last event id
        OPassAPI.lastEventId = ""
        self.dismiss(animated: true, completion: nil)
    }

    @objc func navSingleTap() {
        //NSLog(@"navSingleTap");
        self.handleNavTapTimes()
    }

    func checkNickName(max: Int = 10, current: Int = 1, _ milliseconds: Int = 500) {
        NSLog("Check Nick Name \(current)/\(max)")
        self.userInfo = OPassAPI.userInfo
        if (self.userInfo != nil) {
            self.moreTableView?.reloadSections([0], with: .automatic)
        } else if (current < max) {
            let delayMSec: DispatchTimeInterval = .milliseconds(milliseconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + delayMSec) {
                self.checkNickName(max: max, current: current + 1, milliseconds)
            }
        }
    }

    func handleNavTapTimes() {
        struct tap {
            static var tapTimes: Int = 0
            static var oldTapTime: Date?
            static var newTapTime: Date?
        }

        tap.newTapTime = Date.init()
        if (tap.oldTapTime == nil) {
            tap.oldTapTime = tap.newTapTime
        }

        if let newTapTime = tap.newTapTime {
            if let oldTapTime = tap.oldTapTime {
                if (newTapTime.timeIntervalSince(oldTapTime) <= 0.25) {
                    tap.tapTimes += 1
                    if (tap.tapTimes >= 10) {
                        NSLog("--  Success tap 10 times  --")
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        if !Constants.isDevMode {
                            NSLog("-- Enable DEV_MODE --")
                            Constants.isDevMode = true
                        } else {
                            NSLog("-- Disable DEV_MODE --")
                            Constants.isDevMode = false
                        }
                        Constants.LoadDevLogoTo(view: self.shimmeringLogoView)
                        tap.tapTimes = 1
                    }
                } else {
                    NSLog("--  Failed, just tap %2d times  --", tap.tapTimes)
                    NSLog("-- Failed to trigger DEV_MODE --")
                    tap.tapTimes = 1
                }
                tap.oldTapTime = tap.newTapTime
            }
        }
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let moreTableView = self.moreTableView else { return CGFloat(0) }
        guard let moreItems = self.moreItems else { return moreTableView.frame.size.height }
        return moreTableView.frame.size.height / CGFloat(moreItems.count + 1)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let moreItems = self.moreItems else { return 0 }
        return moreItems.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: NSInteger) -> String? {
        return (self.userInfo?.UserId.count ?? 0) > 0 ? String(format: NSLocalizedString("Hi", comment: ""), self.userInfo?.UserId ?? "") : nil;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let moreItems = self.moreItems {
            if let item = moreItems.object(at: indexPath.row) as? NSArray {
                let feature = item[1] as? EventFeatures
                if let cellId = item[0] as? String {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? MoreCell {
                        cell.Feature = feature
                        cell.backgroundColor = .clear

                        let cellIconId = NSLocalizedString("icon-\(cellId)", comment: "");

                        // FontAwesome Icon
                        if let classId = cellIconId.split(separator: " ").first {
                            var fontStyle: FontAwesomeStyle {
                                switch String(classId) {
                                case "fas":
                                    return FontAwesomeStyle.solid
                                case "fab":
                                    return FontAwesomeStyle.brands
                                default:
                                    return FontAwesomeStyle.solid
                                }
                            }

                            if let fontName = FontAwesome(rawValue: String(cellIconId.split(separator: " ").last ?? "")) {
                                if let iV = cell.imageView {
                                    iV.image = UIImage.fontAwesomeIcon(name: fontName, style: fontStyle, textColor: UIColor.black, size: CGSize(width: 24, height: 24))
                                }
                                }
                        }

                        // Custome Icon
                        if let customIconUrl = feature?.Icon {
                            ImagePipeline.shared.loadImage(
                                with: customIconUrl,
                                progress: { _, _, _ in
                                    print("progress updated")
                                },
                                completion: { (result: Result<ImageResponse, ImagePipeline.Error>) in
                                    print("task completed")
                                    cell.imageView?.image = try? result.get().image.scaled(to: CGSize(width: 24, height: 24))
                                }
                            )
                        }

                        let cellText = [ACKNOWLEDGEMENTS, INTERNAL_CONFIG].contains(where: { $0 == cellId } ) ?
                            NSLocalizedString(cellId, comment: "") :
                            (feature?.DisplayText[Constants.shortLangUI] ?? "")
                        if ((OPassAPI.userInfo?.Role ?? "").count > 0 && !(feature?.VisibleRoles?.contains(OPassAPI.userInfo?.Role ?? "") ?? true)) {
                            cell.isUserInteractionEnabled = false
                        }

                        cell.textLabel?.text = cellText
                        return cell;
                    }
                }
            }
        }
        return tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? MoreCell else { return }
        switch (cell.Feature?.Feature) {
        case OPassKnownFeatures.WebView.rawValue:
            guard let url = cell.Feature?.Url else { break }
            Constants.OpenInAppSafari(forURL: url)
            break
        case OPassKnownFeatures.WiFiConnect.rawValue:
            guard let wifi = cell.Feature?.WiFi.first else { break }
            NEHotspot.ConnectWiFi(SSID: wifi.SSID, withPass: wifi.Password)
            break
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBSegueAction func addInternalConfigView(_ coder: NSCoder) -> UIViewController? {
        if let hostingController = UIHostingController(coder: coder, rootView: InternalConfigView()) {
            hostingController.view.backgroundColor = UIColor.clear;
            return hostingController
        }
        return nil
    }
}
