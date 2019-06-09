//
//  ScheduleAbstractViewCell.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/10.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import UIKit

class ScheduleAbstractViewCell : UITableViewCell {
    @IBOutlet public var vwContent: UIView?
    @IBOutlet public var lbAbstractTitle: UILabel?
    @IBOutlet public var lbAbstractContent: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        // add LineSpacing setting.
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.lineSpacing = 2

        // counting label height
        let constraintRect = CGSize(width: CGFloat(290), height: CGFloat(MAXFLOAT))
        let boundingAttribute = [
            NSAttributedString.Key.font: self.lbAbstractContent!.font,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        let boundingBox = NSString(string: self.lbAbstractContent!.text!).boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: boundingAttribute, context: nil)

        // counting cell height
        let newHeight = 81 + boundingBox.size.height + 48

        return CGSize(width: size.width, height: newHeight)
    }
}
