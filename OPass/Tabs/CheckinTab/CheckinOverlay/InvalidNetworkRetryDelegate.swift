//
//  InvalidNetworkRetryDelegate.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  2019 OPass.
//

import Foundation

@objc protocol InvalidNetworkRetryDelegate {
    @objc var controllerTopStart: CGFloat { get set }
    @objc optional func refresh()
}
