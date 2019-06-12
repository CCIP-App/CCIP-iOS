//
//  SessionDetailViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/13.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import UIKit
import FSPagerView

class SessionDetailViewController: UIViewController, UITableViewDelegate, FSPagerViewDelegate, FSPagerViewDataSource {
    @IBOutlet public var vContent: UIView?
    @IBOutlet public var vwHeader: FSPagerView?
    @IBOutlet public var vwMeta: UIView?
    @IBOutlet public var lbSpeaker: UILabel?
    @IBOutlet public var lbSpeakerName: UILabel?
    @IBOutlet public var lbTitle: UILabel?
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

        self.vwHeader?.setGradientColor(from: AppDelegate.appConfigColor("SessionTitleLeftColor"), to: AppDelegate.appConfigColor("SessionTitleRightColor"), startPoint: CGPoint(x: 1, y: 0.5), toPoint: CGPoint(x: -0.4, y: 0.5))

        // following constraint for fix the storyboard autolayout broken the navigation bar alignment
        self.view.addConstraint(NSLayoutConstraint.init(item: self.vwHeader!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0))

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
            lb?.textColor = AppDelegate.appConfigColor("SessionDetailHeaderTextColor")
        }
        for lb in lbsMeta {
            lb?.textColor = AppDelegate.appConfigColor("SessionMetaHeaderTextColor")
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

        let markdownStyleString = "<style>h1, h2 {color: \(AppDelegate.appConfig("Themes.CardTextColor"))} h3, h4, h5, h6, h7, span, div, p {color: black;}</style>\n\n"
        self.downView = MarkdownView.init(CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.vContent!.bounds.size.height), withMarkdown: markdownStyleString, toView: self.vContent!)
        let description = self.session!["description"]
        NSLog("Set description: \(description)")
        let isEmptyAbstract = description.trim().count == 0
        if !isEmptyAbstract {
            self.downView?.append("# Abstract\n\n\(description)\n\n")
        }
        for speaker in self.session!.Speakers {
            let speakerName = speaker["name"]
            let bio = "\(speaker["bio"])\n"
            NSLog("Set bio for \(speakerName): \(bio)")
            self.downView?.append("---\n\n## \(speakerName)\n\n\(bio)\n\n")
        }
        if isEmptyAbstract && self.session!.Speakers.count == 0 {
            self.downView?.append("## \(NSLocalizedString("EmptySessionDetailContent", comment: ""))")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.vwHeader?.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        self.vwHeader?.delegate = self
        self.vwHeader?.dataSource = self
        self.vwHeader?.isInfinite = true

        if self.session!.Speakers.count > 1 {
            self.vwHeader?.automaticSlidingInterval = 3
        }

        if self.fspager == nil {
            self.fspager = self.vwHeader!.subviews.last!
            self.fspager?.isUserInteractionEnabled = false
//            self.vwHeader?.sendSubviewToBack(self.fspager!)
            self.vwHeader?.bringSubviewToFront(self.vwMeta!)
            self.vwHeader?.bringSubviewToFront(self.lbTitle!)
            self.vwHeader?.bringSubviewToFront(self.lbSpeaker!)
            self.vwHeader?.bringSubviewToFront(self.lbSpeakerName!)
        }

        // force to use Down Markdown view
        let startTime = Constants.DateFromString(self.session!.Start)
        let endTime = Constants.DateFromString(self.session!.End)
        let startTimeString = Constants.DateToDisplayTimeString(startTime)
        let endTimeString = Constants.DateToDisplayTimeString(endTime)

        self.lbSpeaker?.isHidden = self.session!.Speakers.count == 0
        self.lbTitle?.text = self.session!["title"]
        self.lbSpeakerName?.text = self.session!.Speakers.first?["name"]
        self.lbRoomText?.text = self.session!.Room
        self.lbTypeText?.text = Constants.GetSessionTypeName(self.session!.Type as Any)
        self.lbTimeText?.text = "\(startTimeString) - \(endTimeString)"
    }

    // MARK: - FSPagerView

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.session!.Speakers.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let defaultIcon = Constants.AssertImage(name: "StaffIconDefault", InBundleName: "PassAssets")
        let speaker = self.session!.Speakers[index]
        let speakerPhotoURL = speaker.Avatar
        NSLog("Loading Speaker Photo -> \(speakerPhotoURL?.absoluteString ?? "n/a")")
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.contentMode = .scaleAspectFit
        Constants.LoadInto(view: cell.imageView!, forURL: speakerPhotoURL!, withPlaceholder: defaultIcon!)
        self.lbSpeakerName?.text = speaker["name"]
        return cell
    }
}
