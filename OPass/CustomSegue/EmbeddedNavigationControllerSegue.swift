//
//  EmbeddedNavigationControllerSegue.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/10/7.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation
import UIKit

class EmbeddedNavigationControllerSegue: UIStoryboardSegue {
    override func perform() {
        self.source.present(self.destination, animated: true, completion: nil)
    }
}
