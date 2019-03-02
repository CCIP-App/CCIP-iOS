//
//  OPassEventCell.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/3/3.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import UIKit
import FoldingCell

class OPassEventCell: FoldingCell {
    var EventId: String = ""
    @IBOutlet weak var EventLogo: UIImageView!
    @IBOutlet weak var EventName: UILabel!

    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        self.backgroundColor = UIColor.clear
        super.awakeFromNib()
    }

    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
}
