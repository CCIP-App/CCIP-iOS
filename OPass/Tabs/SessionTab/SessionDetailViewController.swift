//
//  SessionDetailViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/13.
//  2019 OPass.
//

import Foundation
import UIKit
import FSPagerView
import WebKit

class SessionDetailViewController: UIViewController, UITableViewDelegate, FSPagerViewDelegate, FSPagerViewDataSource {
    @IBOutlet public var vContent: UIView?
    @IBOutlet public var vwHeader: FSPagerView?
    @IBOutlet public var vwMeta: UIView?
    @IBOutlet public var lbSpeaker: UILabel?
    @IBOutlet public var lbSpeakerName: UILabel?
    @IBOutlet public var lbTitle: UILabel?
    @IBOutlet public var btnFavorite: UIButton?
    @IBOutlet public var lbRoom: UILabel?
    @IBOutlet public var lbRoomText: UILabel?
    @IBOutlet public var lbType: UILabel?
    @IBOutlet public var lbTypeText: UILabel?
    @IBOutlet public var lbTime: UILabel?
    @IBOutlet public var lbTimeText: UILabel?

    private var downView: MarkdownView?
    private var fspager: UIView?
    private var session: SessionInfo?

    public func setSessionData(_ sessionData: SessionInfo) {
        self.session = sessionData
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Constants.SendFib("SessionDetailViewController")

        self.vwHeader?.setGradientColor(from: Constants.appConfigColor.SessionTitleLeftColor, to: Constants.appConfigColor.SessionTitleRightColor, startPoint: CGPoint(x: 1, y: 0.5), toPoint: CGPoint(x: -0.4, y: 0.5))

        // following constraint for fix the storyboard autolayout broken the navigation bar alignment
        guard let vwH = self.vwHeader else { return }
        self.view.addConstraint(NSLayoutConstraint.init(item: vwH, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0))

        let lbsHeader = [
            self.lbSpeaker,
            self.lbSpeakerName,
            self.lbTitle
        ]
        let lbsMeta = [
            self.lbRoom,
            self.lbRoomText,
            self.lbType,
            self.lbTypeText,
            self.lbTime,
            self.lbTimeText
        ]
        for lb in lbsHeader {
            lb?.textColor = Constants.appConfigColor.SessionDetailHeaderTextColor
        }
        for lb in lbsMeta {
            lb?.textColor = Constants.appConfigColor.SessionMetaHeaderTextColor
        }
        for lb in (lbsHeader + lbsMeta) {
            lb?.layer.shadowColor = UIColor.gray.cgColor
            lb?.layer.shadowRadius = 3
            lb?.layer.shadowOpacity = 0.8
            lb?.layer.shadowOffset = CGSize()
            lb?.layer.masksToBounds = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let vContent = self.vContent else { return }

        let markdownStyleString = "<style>h1, h2 { color: \( Constants.appConfigColor.CardTextColor ?? "black"); } h3, h4, h5, h6, h7, span, div, p { color: black; } body { font-size: 1em; padding-top: 0; } a[href] { text-decoration-line: underline; } table#meta { overflow: initial; word-break: break-all; } table#meta tr td:nth-child(1) { text-align: right; word-break: keep-all; color: \( Constants.appConfigColor.CardTextColor ?? "black") } table#meta tr, table#meta td, table#meta th { background-color: transparent; border: none; }</style>\n\n"
        let webConfig = WKWebViewConfiguration()
        webConfig.dataDetectorTypes = [.link]
        self.downView = MarkdownView.init(markdownStyleString, toView: vContent, config: webConfig)

        // add loaded script for removing a[href] default style of color attribute
        self.downView?.append("<script>const mdLoaded = () => {Array.from(document.querySelectorAll('a[href]')).map(n => n.style.color='');}</script>\n\n")

        var metatable = ""
        func meta(_ mData: String?, _ langKey: String?) {
            if let mData = mData {
                var lang = ""
                if let l = langKey {
                    lang = NSLocalizedString("Session_\(l)", comment: "")
                }
                metatable += mData.count > 0 ? "<tr><td>\(lang)</td><td>\(mData)</td></tr>" : ""
            }
        }
        meta(self.session?.Language, "Language")
        meta(self.session?.Slide, "Slide")
        meta(self.session?.Live, "Live")
        meta(self.session?.Record, "Record")
        meta(self.session?.Broadcast, "Broadcast")
        meta(self.session?.CoWrite, "CoWrite")
        meta(self.session?.QA, "QA")
        if metatable.count > 0 {
            self.downView?.append("<table id=\"meta\">\(metatable)</table>\n\n---\n\n")
        }

        let description = self.session?["description"] ?? ""
        NSLog("Set description: \(description)")
        let isEmptyAbstract = description.trim().count == 0
        if !isEmptyAbstract {
            self.downView?.append("# Abstract\n\n\(description)\n\n")
        }
        for speaker in self.session?.Speakers ?? [] {
            let speakerName = speaker["name"]
            let bio = "\(speaker["bio"])\n"
            NSLog("Set bio for \(speakerName): \(bio)")
            self.downView?.append("---\n\n## \(speakerName)\n\n\(bio)\n\n")
        }
        if isEmptyAbstract && (self.session?.Speakers.count ?? 0) == 0 {
            self.downView?.append("## \(NSLocalizedString("EmptySessionDetailContent", comment: ""))")
        }

        // call mdLoaded for removing a[href] default style of color attribute
        self.downView?.append("\n\n<script>setTimeout(() => { mdLoaded(); }, 500)</script>\n\n")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.vwHeader?.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        self.vwHeader?.delegate = self
        self.vwHeader?.dataSource = self
        self.vwHeader?.isInfinite = true

        if (self.session?.Speakers.count ?? 0) > 1 {
            self.vwHeader?.automaticSlidingInterval = 3
        }

        if self.fspager == nil {
            if let pager = self.vwHeader?.subviews.last {
                self.fspager = pager
                self.fspager?.isUserInteractionEnabled = false
                // self.vwHeader?.sendSubviewToBack(self.fspager!)
            }
            if let meta = self.vwMeta {
                self.vwHeader?.bringSubviewToFront(meta)
            }
            if let title = self.lbTitle {
                self.vwHeader?.bringSubviewToFront(title)
            }
            if let speaker = self.lbSpeaker {
                self.vwHeader?.bringSubviewToFront(speaker)
            }
            if let speakerName = self.lbSpeakerName {
                self.vwHeader?.bringSubviewToFront(speakerName)
            }
        }

        // force to use Down Markdown view
        guard let session = self.session else { return }
        let startTime = Constants.DateFromString(session.Start)
        let endTime = Constants.DateFromString(session.End)
        let startTimeString = Constants.DateToDisplayTimeString(startTime)
        let endTimeString = Constants.DateToDisplayTimeString(endTime)

        self.lbSpeaker?.isHidden = session.Speakers.count == 0
        self.lbTitle?.text = session["title"]
        self.lbSpeakerName?.text = session.Speakers.first?["name"]
        self.lbRoomText?.text = session.Room
        let type = session.Type ?? ""
        self.lbType?.isHidden = type.count == 0
        self.lbTypeText?.text = type
        self.lbTimeText?.text = "\(startTimeString) - \(endTimeString)"

        self.checkFavoriteState()
    }

    func checkFavoriteState() {
        guard let token = Constants.accessToken else { return }
        guard let eventInfo = OPassAPI.eventInfo else { return }
        guard let session = self.session else { return }
        let favorite = OPassAPI.CheckFavoriteState(eventInfo.EventId, token, session.Id)
        self.btnFavorite?.setAttributedTitle(Constants.attributedFontAwesome(ofCode: "fa-heart", withSize: 20, inStyle: favorite ? .solid : .regular, forColor: .white), for: .normal)
    }

    @IBAction func favoriteTouchDownAction(_ sender: Any) {
        UIImpactFeedback.triggerFeedback(.impactFeedbackMedium)
    }

    @IBAction func favoriteTouchUpInsideAction(_ sender: Any) {
        guard let token = Constants.accessToken else { return }
        guard let eventInfo = OPassAPI.eventInfo else { return }
        guard let session = self.session else { return }
        OPassAPI.TriggerFavoriteSession(eventInfo.EventId, token, session.Id, session)
        self.checkFavoriteState()
        UIImpactFeedback.triggerFeedback(.impactFeedbackLight)
    }

    @IBAction func favoriteTouchUpOutsideAction(_ sender: Any) {
        UIImpactFeedback.triggerFeedback(.impactFeedbackLight)
    }

    // MARK: - FSPagerView

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        guard let session = self.session else {
            return 0
        }
        return session.Speakers.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        guard let session = self.session else {
            return pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: 0)
        }
        let defaultIcon = Constants.AssertImage(name: "StaffIconDefault", InBundleName: "PassAssets")
        let speaker = session.Speakers[index]
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        if let cellIv = cell.imageView {
            cellIv.contentMode = .scaleAspectFit
            NSLog("Loading Speaker Photo -> \(speaker.Avatar?.absoluteString ?? "n/a")")
            if let icon = defaultIcon {
                if let speakerPhotoURL = speaker.Avatar {
                    Constants.LoadInto(view: cellIv, forURL: speakerPhotoURL, withPlaceholder: icon)
                }
            }
        }
        self.lbSpeakerName?.text = speaker["name"]
        return cell
    }
}
