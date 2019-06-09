//
//  ScheduleFavoriteDelegate.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/9.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation

@objc public protocol ScheduleFavoriteDelegate: NSObjectProtocol {
    @objc func getID(_ program: NSDictionary) -> String
    func actionFavorite(_ scheduleId: String)
    func hasFavorite(_ scheduleId: String) -> Bool
}
