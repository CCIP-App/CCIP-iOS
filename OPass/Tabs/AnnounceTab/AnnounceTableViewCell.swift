//
//  AnnounceTableViewCell.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/3/16.
//  2019 OPass.
//

import Foundation
import UIKit
import UIView_FDCollapsibleConstraints
import UITableView_FDTemplateLayoutCell

class AnnounceTableViewCell: UITableViewCell {
    @IBOutlet public var vwShadowContent: UIView!
    @IBOutlet public var vwMessageTime: UIView!
    @IBOutlet public var vwURL: UIView!
    @IBOutlet public var vwContent: UIView!
    @IBOutlet public var lbMessage: UILabel!
    @IBOutlet public var lbMessageTime: UILabel!
    @IBOutlet public var vwDashedLine: UIView!
    @IBOutlet public var lbIconOfURL: UILabel!
    @IBOutlet public var lbURL: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        //    float width = [UIScreen mainScreen].applicationFrame.size.width;
        //    self.msg.preferredMaxLayoutWidth = width - 60;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
