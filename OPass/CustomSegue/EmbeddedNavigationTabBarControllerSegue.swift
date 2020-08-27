//
//  EmbeddedNavigationTabBarControllerSegue.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/10/7.
//  2018 OPass.
//

import Foundation
import UIKit
import Then
import SwiftDate

class EmbeddedNavigationTabBarControllerSegue: UIStoryboardSegue {
    override func perform() {
        guard let navController = self.source.navigationController else { return }
        let destinationView: UIView = self.destination.view
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let navBarHeight = navController.navigationBar.frame.size.height
        let tabBarHeight = CGFloat(0.0) //(self.source.tabBarController?.tabBar.frame.size.height)!
        let height = screenHeight - (destinationView.ViewTopStart + navBarHeight + tabBarHeight)
        let frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: screenWidth, height: height))
        destinationView.frame = frame.offsetBy(dx: 0, dy: screenHeight)
        destinationView.alpha = 0
        Promise { resolve, _ in
            DispatchQueue.main.async {
                self.source.present(self.destination, animated: false) {
                    guard let dest = destinationView.superview else {
                        resolve()
                        return
                    }
                    dest.frame = CGRect(origin: CGPoint(x: 0, y: dest.ViewTopStart + navBarHeight), size: CGSize(width: screenWidth, height: height))
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
