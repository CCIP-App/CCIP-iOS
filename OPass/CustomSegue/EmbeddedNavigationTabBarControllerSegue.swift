//
//  EmbeddedNavigationTabBarControllerSegue.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/10/7.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation
import UIKit
import then
import SwiftDate

class EmbeddedNavigationTabBarControllerSegue: UIStoryboardSegue {
    override func perform() {
        let destinationView: UIView = self.destination.view
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let navBarHeight = (self.source.navigationController?.navigationBar.frame.size.height)!
        let tabBarHeight = (self.source.tabBarController?.tabBar.frame.size.height)!
        let height = screenHeight - (destinationView.ViewTopStart + navBarHeight + tabBarHeight)
        let frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: screenWidth, height: height))
        destinationView.frame = frame.offsetBy(dx: 0, dy: screenHeight)
        destinationView.alpha = 0
        Promise { resolve, reject in
            DispatchQueue.main.async {
                self.source.present(self.destination, animated: false) {
                    destinationView.superview!.frame = CGRect(origin: CGPoint(x: 0, y: destinationView.superview!.ViewTopStart + navBarHeight), size: CGSize(width: screenWidth, height: height))
                    destinationView.alpha = 1
                    resolve()
                }
            }
        }.then { _ in
            DispatchQueue.main.async {
                destinationView.frame = frame.offsetBy(dx: 0, dy: screenHeight)
                UIView.animate(
                    withDuration: 400000000.nanoseconds.timeInterval,
                    delay: 0,
                    options: [ .curveEaseInOut, .preferredFramesPerSecond60 ],
                    animations: {
                        destinationView.frame = frame
                    }
                )
            }
        }
    }
}
