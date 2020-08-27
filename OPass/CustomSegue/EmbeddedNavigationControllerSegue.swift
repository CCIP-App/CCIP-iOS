//
//  EmbeddedNavigationControllerSegue.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/10/7.
//  2018 OPass.
//

import Foundation
import UIKit
import Then
import Device_swift

class EmbeddedNavigationControllerSegue: UIStoryboardSegue {
    override func perform() {
        let destinationView: UIView = self.destination.view
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

//        let navBarHeight = (self.source.navigationController?.navigationBar.frame.size.height)!
//        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
//        let tabBarHeight = (self.source.tabBarController?.tabBar.frame.size.height)!

        var frameHeight: CGFloat
        var superViewHeight: CGFloat
        var superViewTop: CGFloat

        var frame: CGRect

//        switch UIDevice.current.deviceType {
//        case .iPhoneSE, .iPhone5C, .iPhone5S:
            frameHeight = screenHeight
            superViewHeight = screenHeight
            superViewTop = 0
//        default:
//            frameHeight = screenHeight - (statusBarHeight + navBarHeight)
//            superViewHeight = screenHeight - (statusBarHeight + navBarHeight + tabBarHeight)
//            superViewTop = statusBarHeight + navBarHeight
//        }

        frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: screenWidth, height: frameHeight))
        destinationView.frame = frame.offsetBy(dx: 0, dy: screenHeight)
        destinationView.alpha = 0

        Promise { resolve, _ in
            DispatchQueue.main.async {
                self.source.present(self.destination, animated: false) {
                    destinationView.superview?.frame = CGRect(origin: CGPoint(x: 0, y: superViewTop), size: CGSize(width: screenWidth, height: superViewHeight))
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
