//
//  Router.swift
//  OPass
//
//  Created by 張智堯 on 2022/8/30.
//  2022 OPass.
//

import SwiftUI

final class Router: ObservableObject{
    @Published var path = NavigationPath()
    
    enum rootDestination: Hashable, Codable {
        case settings
        case appearance
        case developers
    }
    
    enum mainDestination: Hashable, Codable {
        case fastpass
        case schedule
        case sessionDetail(SessionDataModel)
        case ticket
        case announcement
    }
}
