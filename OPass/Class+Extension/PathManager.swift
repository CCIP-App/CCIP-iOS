//
//  PathManager.swift
//  OPass
//
//  Created by 張智堯 on 2022/8/30.
//  2022 OPass.
//

import SwiftUI

final class PathManager: ObservableObject{
    @Published var path: [destination] = []
    
    enum destination: Hashable, Codable {
        case fastpass
        case schedule
        case sessionDetail(SessionDataModel)
        case ticket
        case announcement
        case settings
        case appearance
        case developers
    }
}
