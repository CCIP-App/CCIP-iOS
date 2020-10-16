//
//  OPassEventCell.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/3/3.
//  2019 OPass.
//

import Foundation
import UIKit
import FoldingCell

class OPassEventCell: FoldingCell {
    var EventId: String = ""
    @IBOutlet weak var EventLogo: UIImageView!
    @IBOutlet weak var EventName: UILabel!

    override func awakeFromNib() {
        self.foregroundView.layer.cornerRadius = 10
        self.foregroundView.backgroundColor = Constants.appConfigColor.colorConfig("EventSwitcherButtonColor")
        self.backgroundColor = UIColor.clear

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.masksToBounds = false

        self.EventLogo.layer.shadowColor = UIColor.black.cgColor
        self.EventLogo.layer.shadowRadius = 4.0
        self.EventLogo.layer.shadowOpacity = 0.3
        self.EventLogo.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.EventLogo.layer.masksToBounds = false

        self.EventName.textColor = Constants.appConfigColor.colorConfig("EventSwitcherTextColor")
        self.EventName.layer.shadowColor = UIColor.black.cgColor
        self.EventName.layer.shadowRadius = 4.0
        self.EventName.layer.shadowOpacity = 0.3
        self.EventName.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.EventName.layer.masksToBounds = false

        super.awakeFromNib()
    }

    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
}
