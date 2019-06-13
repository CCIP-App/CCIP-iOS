//
//  SessionViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/9.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import UIKit

class SessionViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let lbTitle = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        lbTitle.textAlignment = .center
        lbTitle.textColor = .white
        lbTitle.text = NSLocalizedString("SessionTitle", comment: "")
        self.navigationItem.title = ""
        self.navigationItem.titleView = lbTitle
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage.init()
        self.navigationController?.navigationBar.backgroundColor = .clear

        let title = Constants.attributedFontAwesome(ofCode: "fa-heart", withSize: 20, inStyle: .solid, forColor: .white)

        let favButton = UIButton.init()
        favButton.setAttributedTitle(title, for: .normal)
        favButton.addTarget(self, action: #selector(showFavoritesTouchDown), for: .touchDown)
        favButton.addTarget(self, action: #selector(showFavoritesTouchUpInside), for: .touchUpInside)
        favButton.addTarget(self, action: #selector(showFavoritesTouchUpOutside), for: .touchUpOutside)
        favButton.sizeToFit()
        let favoritesButton = UIBarButtonItem.init(customView: favButton)
        self.navigationItem.setRightBarButton(favoritesButton, animated: true)

        let titleFake = Constants.attributedFontAwesome(ofCode: "fa-heart", withSize: 20, inStyle: .solid, forColor: .clear)

        let favButtonFake = UIButton.init()
        favButtonFake.setAttributedTitle(titleFake, for: .normal)
        favButtonFake.sizeToFit()
        let favoritesButtonFake = UIBarButtonItem.init(customView: favButtonFake)
        self.navigationItem.setLeftBarButton(favoritesButtonFake, animated: true)

        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 239)
        let headView = UIView.init(frame: frame)
        headView.setGradientColor(from: AppDelegate.appConfigColor("SessionTitleLeftColor"), to: AppDelegate.appConfigColor("SessionTitleRightColor"), startPoint: CGPoint(x: -0.4, y: 0.5), toPoint: CGPoint(x: 1, y: 0.5))
        self.view.addSubview(headView)
        self.view.sendSubviewToBack(headView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
    }

    @objc func showFavoritesTouchDown() {
        UIImpactFeedback.triggerFeedback(.impactFeedbackMedium)
    }

    @objc func showFavoritesTouchUpInside() {
        self.performSegue(withIdentifier: "ShowFavorites", sender: nil)
        UIImpactFeedback.triggerFeedback(.impactFeedbackLight)
    }

    @objc func showFavoritesTouchUpOutside() {
        UIImpactFeedback.triggerFeedback(.impactFeedbackLight)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFavorites" {
            let vc = segue.destination as? SessionFavoriteTableViewController
            vc?.pagerController = self.children.first! as? SessionViewPagerController
        }
    }
}
