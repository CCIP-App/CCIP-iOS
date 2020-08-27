//
//  SessionFavoriteTableViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/13.
//  2019 OPass.
//

import Foundation
import UIKit

class SessionFavoriteTableViewController: SessionTableViewController {
    private static var headView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let navBar = self.navigationController?.navigationBar else { return }
        navBar.backgroundColor = .clear

        let title = Constants.attributedFontAwesome(ofCode: "fa-heart", withSize: 20, inStyle: .solid, forColor: .white)
        let lbTitle = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        lbTitle.textAlignment = .center
        lbTitle.textColor = .white
        lbTitle.attributedText = title
        self.navigationItem.title = ""
        self.navigationItem.titleView = lbTitle

        let navigationBarBounds = navBar.bounds
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: navBar.frame.origin.y + navigationBarBounds.size.height)

        SessionFavoriteTableViewController.headView = UIView.init(frame: frame)

        guard let headView = SessionFavoriteTableViewController.headView else { return }
        guard let navController = self.navigationController else { return }
        navBar.superview?.addSubview(headView)
        navBar.superview?.bringSubviewToFront(headView)
        navBar.superview?.bringSubviewToFront(navController.navigationBar)

        let titleFake = Constants.attributedFontAwesome(ofCode: "fa-heart", withSize: 20, inStyle: .solid, forColor: .clear)
        let favButtonFake = UIButton.init()
        favButtonFake.setAttributedTitle(titleFake, for: .normal)
        favButtonFake.setTitleColor(.clear, for: .normal)
        favButtonFake.sizeToFit()
        let favoritesButtonFake = UIBarButtonItem.init(customView: favButtonFake)
        self.navigationItem.setRightBarButton(favoritesButtonFake, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SessionFavoriteTableViewController.headView?.setGradientColor(from: Constants.appConfigColor.SessionTitleLeftColor, to: Constants.appConfigColor.SessionTitleRightColor, startPoint: CGPoint(x: -0.4, y: 0.5), toPoint: CGPoint(x: 1, y: 0.5))
        SessionFavoriteTableViewController.headView?.alpha = 0
        SessionFavoriteTableViewController.headView?.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            SessionFavoriteTableViewController.headView?.alpha = 1
        }) { _ in
            SessionFavoriteTableViewController.headView?.alpha = 1
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SessionFavoriteTableViewController.headView?.setGradientColor(from: .clear, to: .clear, startPoint: CGPoint(x: -0.4, y: 0.5), toPoint: CGPoint(x: 1, y: 0.5))
    }

    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            SessionFavoriteTableViewController.headView?.removeFromSuperview()
        }
    }

    override func show(_ vc: UIViewController, sender: Any?) {
        UIView.animate(withDuration: 0.5, animations: {
            SessionFavoriteTableViewController.headView?.alpha = 0
        }) { _ in
            SessionFavoriteTableViewController.headView?.isHidden = true
            SessionFavoriteTableViewController.headView?.alpha = 1
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == Constants.SESSION_DETAIL_VIEW_STORYBOARD_ID {
            guard let detailView = segue.destination as? SessionDetailViewController else { return }
            guard let session = self.pagerController?.programs?.GetSession(sender as? String ?? "") else { return }
            detailView.setSessionData(session)
        }
    }
}
