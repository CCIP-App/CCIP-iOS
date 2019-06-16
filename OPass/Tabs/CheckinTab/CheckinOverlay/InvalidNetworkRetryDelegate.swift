//
//  InvalidNetworkRetryDelegate.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation

@objc protocol InvalidNetworkRetryDelegate {
    @objc optional func refresh()
}
