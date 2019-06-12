//
//  SessionFavoriteDelegate.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/9.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation

@objc public protocol SessionFavoriteDelegate: NSObjectProtocol {
    func actionFavorite(_ sessionId: String)
    func hasFavorite(_ sessionId: String) -> Bool
}
