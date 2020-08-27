//
//  SessionTableViewCell.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/9.
//  2019 OPass.
//

import Foundation
import UIKit
import TagListView
import Then
import SwiftDate

class SessionTableViewCell: UITableViewCell, TagListViewDelegate {
    @IBOutlet weak var SessionTitleLabel: UILabel!
    @IBOutlet weak var SpeakerNamesLabel: UILabel!
    @IBOutlet weak var RoomLocationLabel: UILabel!
    @IBOutlet weak var TagList: TagListView!
    @IBOutlet weak var FavoriteButton: UIButton!

    private var favorite: Bool = false
    private var disabled: Bool = false
    private var session: SessionInfo?
    private var sessionId: String? {
        return self.session?.Id
    }

    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        NSLog("Tag pressed: \(title), \(sender)")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.TagList.delegate = self
        self.TagList.textFont = UIFont.systemFont(ofSize: 12)
        self.TagList.textColor = UIColor.colorFromHtmlColor("#9b9b9b")
        self.TagList.backgroundColor = .clear
        self.TagList.tagBackgroundColor = UIColor.colorFromHtmlColor("#d8d8d8")
        self.TagList.tagLineBreakMode = .byClipping
        self.TagList.cornerRadius = 3
        self.TagList.paddingX = 8
        self.TagList.paddingY = 5
        self.TagList.marginX = 5
        self.TagList.marginY = 3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBAction func favoriteTouchDownAction(_ sender: NSObject) {
        UIImpactFeedback.triggerFeedback(.impactFeedbackMedium)
    }

    @IBAction func favoriteTouchUpInsideAction(_ sender: NSObject) {
        guard let token = Constants.accessToken else { return }
        guard let eventInfo = OPassAPI.eventInfo else { return }
        guard let session = self.session else { return }
        guard let sessionId = self.sessionId else { return }
        OPassAPI.TriggerFavoriteSession(eventInfo.EventId, token, sessionId, session)
        self.setFavorite(OPassAPI.CheckFavoriteState(eventInfo.EventId, token, sessionId))
        UIImpactFeedback.triggerFeedback(.impactFeedbackLight)
    }

    @IBAction func favoriteTouchUpOutsideAction(_ sender: NSObject) {
        UIImpactFeedback.triggerFeedback(.impactFeedbackLight)
    }

    func setSession(_ session: SessionInfo) {
        self.session = session
        self.displayContents()
    }

    func getSession() -> SessionInfo? {
        return self.session
    }

    func setFavorite(_ favorite: Bool) {
        DispatchQueue.global(qos: .background).async {
        self.favorite = favorite
            let title = Constants.attributedFontAwesome(ofCode: "fa-heart", withSize: 20, inStyle: self.favorite ? .solid : .regular, forColor: Constants.appConfigColor.FavoriteButtonColor)
            DispatchQueue.main.async {
                self.FavoriteButton.setAttributedTitle(title, for: .normal)
            }
        }
    }

    func getFavorite() -> Bool {
        return self.favorite
    }

    func setDisabled(_ disabled: Bool) {
        self.disabled = disabled
        self.SessionTitleLabel.alpha = self.disabled ? 0.2 : 1
    }

    func getDisabled() -> Bool {
        return self.disabled
    }

    func displayContents() {
        guard let token = Constants.accessToken else { return }
        guard let eventInfo = OPassAPI.eventInfo else { return }
        guard let session = self.session else { return }
        guard let sessionId = self.sessionId else { return }
        guard let room = session.Room else { return }

        let speakers = session.Speakers.map({ speaker -> String in
            return speaker["name"]
        }).joined(separator: ", ")
        let startTime = Constants.DateFromString(session.Start)
        let endTime = Constants.DateFromString(session.End)
        let mins = Int(endTime.timeIntervalSince(startTime) / 60)
        let type = session.Type ?? ""
        let tags = ([ session.Language ] + ( session.Tags.map { $0.Name.trim() } ) + [ type ]).filter { $0.count > 0 }
        let state = OPassAPI.CheckFavoriteState(eventInfo.EventId, token, sessionId)

        self.SpeakerNamesLabel.text = speakers.count > 0 ? "Speaker(s): " + speakers : ""
        self.RoomLocationLabel.text = "Room \(room) - \(mins) mins"
        self.SessionTitleLabel.text = session["title"]
        self.TagList.removeAllTags()
        self.TagList.addTags(tags)
        self.setFavorite(state)
    }
}
