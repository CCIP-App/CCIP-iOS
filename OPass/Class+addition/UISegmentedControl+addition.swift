//
//  UISegmentedControl+addition.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation
import UIKit

extension UISegmentedControl {
    func resetAllSegments(_ segments: NSArray) {
        let oldIndex : NSInteger = self.selectedSegmentIndex;
        let oldTitle : String? = oldIndex != -1 ? self.titleForSegment(at: oldIndex) : nil;
        self.removeAllSegments();

        for i in 0..<segments.count {
            let title : String = segments.object(at: i) as! String;
            self.insertSegment(withTitle: title, at: self.numberOfSegments, animated: false);
            if (title == oldTitle) {
                self.selectedSegmentIndex = i;
            }
        }
    }
}
