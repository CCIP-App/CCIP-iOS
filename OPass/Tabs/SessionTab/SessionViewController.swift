//
//  SessionViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/9.
//  2019 OPass.
//

import Foundation
import UIKit

class SessionViewController: UIViewController {
    internal var endpointKey: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let lbTitle = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        lbTitle.textAlignment = .center
        lbTitle.textColor = .white
        lbTitle.text = NSLocalizedString("SessionTitle", comment: "")
        if let tabIndex = self.tabBarController?.selectedIndex {
            if let currentItems = self.tabBarController?.tabBar.items {
                let item = currentItems[tabIndex]
                lbTitle.text = item.title
                self.endpointKey = item.accessibilityValue
            }
        }
        self.navigationItem.title = ""
        self.navigationItem.titleView = lbTitle
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage.init()
        self.navigationController?.navigationBar.backgroundColor = .clear

        // Create Favorite button
        let title_Favorites = Constants.attributedFontAwesome(ofCode: "fa-heart", withSize: 20, inStyle: .solid, forColor: .white)

        let uiButton_Favorites = UIButton.init()
        uiButton_Favorites.setAttributedTitle(title_Favorites, for: .normal)
        uiButton_Favorites.addTarget(self, action: #selector(showFavoritesTouchDown), for: .touchDown)
        uiButton_Favorites.addTarget(self, action: #selector(showFavoritesTouchUpInside), for: .touchUpInside)
        uiButton_Favorites.addTarget(self, action: #selector(showFavoritesTouchUpOutside), for: .touchUpOutside)
        uiButton_Favorites.sizeToFit()
        let uiBarButton_Favorites = UIBarButtonItem.init(customView: uiButton_Favorites)

        // Create Search button
        let title_Search = Constants.attributedFontAwesome(ofCode: "fa-search", withSize: 20, inStyle: .solid, forColor: .white)

        let uiButton_Search = UIButton.init()
        uiButton_Search.setAttributedTitle(title_Search, for: .normal)
        uiButton_Search.addTarget(self, action: #selector(showSearchTouchDown), for: .touchDown)
        uiButton_Search.addTarget(self, action: #selector(showSearchTouchUpInside), for: .touchUpInside)
        uiButton_Search.addTarget(self, action: #selector(showSearchTouchUpOutside), for: .touchUpOutside)
        uiButton_Search.sizeToFit()
        let uiBarButton_Search = UIBarButtonItem.init(customView: uiButton_Search)

        // Create Fake button
        let title_Fake = Constants.attributedFontAwesome(ofCode: "fa-heart", withSize: 20, inStyle: .solid, forColor: .clear)

        let uiButton_Fake = UIButton.init()
        uiButton_Fake.setAttributedTitle(title_Fake, for: .normal)
        uiButton_Fake.sizeToFit()
        let uiBarButton_Fake = UIBarButtonItem.init(customView: uiButton_Fake)

        // Set Navigation Buttons
        self.navigationItem.setRightBarButtonItems([uiBarButton_Favorites, uiBarButton_Search], animated: true)
        self.navigationItem.setLeftBarButtonItems([uiBarButton_Fake, uiBarButton_Fake], animated: true)

        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 239)
        let headView = UIView.init(frame: frame)
        headView.setGradientColor(from: Constants.appConfigColor.SessionTitleLeftColor, to: Constants.appConfigColor.SessionTitleRightColor, startPoint: CGPoint(x: -0.4, y: 0.5), toPoint: CGPoint(x: 1, y: 0.5))
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

    @objc func showSearchTouchDown() {
        UIImpactFeedback.triggerFeedback(.impactFeedbackMedium)
    }

    @objc func showSearchTouchUpInside() {
        self.performSegue(withIdentifier: "ShowSearch", sender: nil)
        UIImpactFeedback.triggerFeedback(.impactFeedbackLight)
    }

    @objc func showSearchTouchUpOutside() {
        UIImpactFeedback.triggerFeedback(.impactFeedbackLight)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowFavorites":
            let vc = segue.destination as? SessionFavoriteTableViewController
            vc?.pagerController = self.children.first as? SessionViewPagerController
            break
        case "ShowSearch":
            let vc = segue.destination as? SessionSearchTableViewController
            vc?.pagerController = self.children.first as? SessionViewPagerController
            break
        default:
            break
        }
    }
}
