//
//  SessionTableViewCell.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/9.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import UIKit

class SessionTableViewCell: UITableViewCell {
    @IBOutlet public var SessionTitleLabel: UILabel?
    @IBOutlet public var RoomLocationLabel: UILabel?
    @IBOutlet public var LabelLabel: UILabel?
    @IBOutlet public var FavoriteButton: UIButton?

    private var favorite: Bool = false
    private var disabled: Bool = false
    private var session: SessionInfo?
    private var sessionId: String? {
        return self.session?.Id
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.LabelLabel?.textColor = UIColor.colorFromHtmlColor("#9b9b9b")
        self.LabelLabel?.backgroundColor = UIColor.colorFromHtmlColor("#d8d8d8")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBAction func favoriteTouchDownAction(_ sender: NSObject) {
        UIImpactFeedback.triggerFeedback(.impactFeedbackMedium)
    }

    @IBAction func favoriteTouchUpInsideAction(_ sender: NSObject) {
        OPassAPI.TriggerFavoriteSession(forEvent: OPassAPI.currentEvent, withToken: AppDelegate.accessToken(), toSession: self.sessionId!)
        self.setFavorite(OPassAPI.CheckFavoriteState(forEvent: OPassAPI.currentEvent, withToken: AppDelegate.accessToken(), toSession: self.sessionId!))
        UIImpactFeedback.triggerFeedback(.impactFeedbackLight)
    }

    @IBAction func favoriteTouchUpOutsideAction(_ sender: NSObject) {
        UIImpactFeedback.triggerFeedback(.impactFeedbackLight)
    }

    func setSession(_ session: SessionInfo) {
        self.session = session

        let startTime = Constants.DateFromString(self.session!.Start)
        let endTime = Constants.DateFromString(self.session!.End)
        let mins = Int(endTime.timeIntervalSince(startTime) / 60)
        self.RoomLocationLabel?.text = "Room \(self.session!.Room!) - \(mins) mins"

        self.SessionTitleLabel?.text = self.session!["title"]

        let type = self.session!.Type ?? ""
        self.LabelLabel?.text = "   \(type)   "
        self.LabelLabel?.layer.cornerRadius = (self.LabelLabel?.frame.size.height)! / 2
        self.LabelLabel?.sizeToFit()
        self.LabelLabel?.isHidden = type.count == 0
        self.setFavorite(false)

        self.setFavorite(OPassAPI.CheckFavoriteState(forEvent: OPassAPI.currentEvent, withToken: AppDelegate.accessToken(), toSession: self.sessionId!))
    }

    func getSession() -> SessionInfo? {
        return self.session
    }

    func setFavorite(_ favorite: Bool) {
        self.favorite = favorite
        let titleAttribute = [
            NSAttributedString.Key.font: Constants.fontOfAwesome(withSize: 20, inStyle: self.favorite ? fontAwesomeStyle.solid : fontAwesomeStyle.regular),
            NSAttributedString.Key.foregroundColor: AppDelegate.appConfigColor("FavoriteButtonColor")
        ]
        let title = NSAttributedString.init(string: Constants.fontAwesome(code: "fa-heart")!, attributes: titleAttribute)
        self.FavoriteButton?.setAttributedTitle(title, for: .normal)
    }

    func getFavorite() -> Bool {
        return self.favorite
    }

    @objc func setDisabled(_ disabled: Bool) {
        self.disabled = disabled
        self.SessionTitleLabel?.alpha = self.disabled ? 0.2 : 1
    }

    func getDisabled() -> Bool {
        return self.disabled
    }
}
