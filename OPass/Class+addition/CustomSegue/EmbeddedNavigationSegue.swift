//
//  EmbeddedNavigationSegue.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/10/7.
//  2018 OPass.
//

import Foundation
import UIKit
import Then
import SwiftDate
import Device_swift

class EmbeddedNavigationSegue: UIStoryboardSegue {
    var destinationView: UIView?
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    var frame: CGRect?

    override func perform() {
        self.destinationView = self.destination.view
    }

    func appeared() {
        DispatchQueue.main.async {
            if let frame = self.frame {
                if let destinationView = self.destinationView {
                    destinationView.frame = frame.offsetBy(dx: 0, dy: self.screenHeight)
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
}

class EmbeddedNavigationTabBarControllerSegue: EmbeddedNavigationSegue {
    override func perform() {
        super.perform()

        guard let navController = self.source.navigationController else { return }

        let navBarHeight = navController.navigationBar.frame.size.height
        let tabBarHeight = CGFloat(0.0)
        if let destinationView = self.destinationView {
            let height = screenHeight - (destinationView.ViewTopStart + navBarHeight + tabBarHeight)
            self.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.screenWidth, height: height))
            if let frame = self.frame {
                destinationView.frame = frame.offsetBy(dx: 0, dy: self.screenHeight)
                destinationView.alpha = 0
                Promise { resolve, _ in
                    DispatchQueue.main.async {
                        self.source.present(self.destination, animated: false) {
                            guard let dest = destinationView.superview else {
                                resolve()
                                return
                            }
                            dest.frame = CGRect(origin: CGPoint(x: 0, y: 2 * dest.ViewTopStart), size: CGSize(width: self.screenWidth, height: height + navBarHeight))
                            destinationView.alpha = 1
                            destinationView.frame = destinationView.frame.offsetBy(dx: 0, dy: navBarHeight)
                            resolve()
                        }
                    }
                }.then { _ in
                   self.appeared()
               }
            }
        }
    }
}

class EmbeddedNavigationControllerSegue: EmbeddedNavigationSegue {
    override func perform() {
        super.perform()

        let frameHeight: CGFloat = self.screenHeight
        let superViewHeight: CGFloat = self.screenHeight
        let superViewTop: CGFloat = 0

        self.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.screenWidth, height: frameHeight))
        if let destinationView = self.destinationView {
            if let frame = self.frame {
                destinationView.frame = frame.offsetBy(dx: 0, dy: self.screenHeight)
                destinationView.alpha = 0
                Promise { resolve, _ in
                    DispatchQueue.main.async {
                        self.source.present(self.destination, animated: false) {
                            destinationView.superview?.frame = CGRect(origin: CGPoint(x: 0, y: superViewTop), size: CGSize(width: self.screenWidth, height: superViewHeight))
                            destinationView.alpha = 1
                            resolve()
                        }
                    }
                }.then { _ in
                    self.appeared()
                }
            }
        }
    }
}
