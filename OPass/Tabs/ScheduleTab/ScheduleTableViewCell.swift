//
//  ScheduleTableViewCell.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/9.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import UIKit

class ScheduleTableViewCell: UITableViewCell {
    public var delegate: ScheduleFavoriteDelegate?
    @IBOutlet public var ScheduleTitleLabel: UILabel?
    @IBOutlet public var RoomLocationLabel: UILabel?
    @IBOutlet public var LabelLabel: UILabel?
    @IBOutlet public var FavoriteButton: UIButton?

    private var favorite: Bool = false
    private var disabled: Bool = false
    private var session: SessionInfo?

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
        self.favorite = !self.favorite
        if (self.delegate != nil) {
            if ((self.delegate?.responds(to: #selector(ScheduleFavoriteDelegate.actionFavorite(_:))))!) {
                self.delegate!.actionFavorite(self.getID())
            }
        }
        UIImpactFeedback.triggerFeedback(.impactFeedbackLight)
    }

    @IBAction func favoriteTouchUpOutsideAction(_ sender: NSObject) {
        UIImpactFeedback.triggerFeedback(.impactFeedbackLight)
    }

    func getID() -> String {
        return self.session?.Id ?? ""
    }

    func setSession(_ session: SessionInfo) {
        self.session = session

        let startTime = Constants.DateFromString(self.session!.Start)
        let endTime = Constants.DateFromString(self.session!.End)
        let mins = Int(endTime.timeIntervalSince(startTime) / 60)
        self.RoomLocationLabel?.text = "Room \(self.session!.Room!) - \(mins) mins"

        self.ScheduleTitleLabel?.text = self.session!["title"]

        let type = Constants.GetScheduleTypeName(self.session!.Type!)
        self.LabelLabel?.text = "   \(type)   "
        self.LabelLabel?.layer.cornerRadius = (self.LabelLabel?.frame.size.height)! / 2
        self.LabelLabel?.sizeToFit()
        self.LabelLabel?.isHidden = type.count == 0
        self.setFavorite(false)

        if (self.delegate != nil) {
            if ((self.delegate?.responds(to: #selector(ScheduleFavoriteDelegate.hasFavorite(_:))))!) {
                self.setFavorite(self.delegate!.hasFavorite(self.getID()))
            }
        }
    }

    func getSession() -> SessionInfo? {
        return self.session
    }

    @objc func setFavorite(_ favorite: Bool) {
        self.favorite = favorite
        let titleAttribute = [
            NSAttributedString.Key.font: Constants.fontOfAwesome(withSize: 20, inStyle: self.favorite ? fontAwesomeStyle.solid : fontAwesomeStyle.regular),
            NSAttributedString.Key.foregroundColor: AppDelegate.appConfigColor("FavoriteButtonColor")
        ]
        let title = NSAttributedString.init(string: Constants.fontAwesome(code: "fa-heart")!, attributes: titleAttribute)
        self.FavoriteButton?.setAttributedTitle(title, for: .normal)
    }

    @objc func getFavorite() -> Bool {
        return self.favorite
    }

    @objc func setDisabled(_ disabled: Bool) {
        self.disabled = disabled
        self.ScheduleTitleLabel?.alpha = self.disabled ? 0.2 : 1
    }

    @objc func getDisabled() -> Bool {
        return self.disabled
    }

    @objc func setDelegate(_ delegate: ScheduleFavoriteDelegate) {
        self.delegate = delegate
    }
}
