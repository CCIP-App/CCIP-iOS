//
//  Router.swift
//  OPass
//
//  Created by Brian Chang on 2023/8/8.
//

import SwiftUI

class Router: ObservableObject {
    @Published var path = NavigationPath()

    @inline(__always)
    func forward(_ destination: any Destination) {
        self.path.append(destination)
    }

    @inline(__always)
    func back() {
        self.path.removeLast()
    }

    @inline(__always)
    func backRoot() {
        self.path.removeLast(path.count)
    }
}

protocol Destination: Hashable {
}
