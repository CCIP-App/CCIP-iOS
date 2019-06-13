//
//  SessionFavoriteTableViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/13.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import UIKit

class SessionFavoriteTableViewController: UITableViewController, UIViewControllerPreviewingDelegate {
    public var pagerController: SessionViewPagerController?

    private static var headView: UIView?
    private var favoritesTimes = Array<Date>()
    private var favoritesSections = Dictionary<String, Array<String>>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForceTouch()

        self.parseFavorites()

        guard let navBar = self.navigationController?.navigationBar else { return }
        navBar.backgroundColor = .clear

        let titleAttributes = [
            NSAttributedString.Key.font: Constants.fontOfAwesome(withSize: 20, inStyle: .solid),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        let title = NSAttributedString.init(string: Constants.fontAwesome(code: "fa-heart")!, attributes: titleAttributes)
        let lbTitle = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        lbTitle.textAlignment = .center
        lbTitle.textColor = .white
        lbTitle.attributedText = title
        self.navigationItem.title = nil
        self.navigationItem.titleView = lbTitle

        let navigationBarBounds = navBar.bounds
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: navBar.frame.origin.y + navigationBarBounds.size.height)

        SessionFavoriteTableViewController.headView = UIView.init(frame: frame)

        navBar.superview?.addSubview(SessionFavoriteTableViewController.headView!)
        navBar.superview?.bringSubviewToFront(SessionFavoriteTableViewController.headView!)
        navBar.superview?.bringSubviewToFront(self.navigationController!.navigationBar)

        let titleAttributeFake = [
            NSAttributedString.Key.font: Constants.fontOfAwesome(withSize: 20, inStyle: .solid),
            NSAttributedString.Key.foregroundColor: UIColor.clear
        ]
        let titleFake = NSAttributedString.init(string: Constants.fontAwesome(code: "fa-heart")!, attributes: titleAttributeFake)
        let favButtonFake = UIButton.init()
        favButtonFake.setAttributedTitle(titleFake, for: .normal)
        favButtonFake.setTitleColor(.clear, for: .normal)
        favButtonFake.sizeToFit()
        let favoritesButtonFake = UIBarButtonItem.init(customView: favButtonFake)
        self.navigationItem.setRightBarButton(favoritesButtonFake, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SessionFavoriteTableViewController.headView?.setGradientColor(from: AppDelegate.appConfigColor("SessionTitleLeftColor"), to: AppDelegate.appConfigColor("SessionTitleRightColor"), startPoint: CGPoint(x: -0.4, y: 0.5), toPoint: CGPoint(x: 1, y: 0.5))
        SessionFavoriteTableViewController.headView?.alpha = 0
        SessionFavoriteTableViewController.headView?.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            SessionFavoriteTableViewController.headView?.alpha = 1
        }) { finished in
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

    func parseFavorites() {
        self.favoritesTimes.removeAll()
        self.favoritesSections.removeAll()
        let favList = OPassAPI.GetFavoritesList(forEvent: OPassAPI.currentEvent, withToken: AppDelegate.accessToken())
        for session in (self.pagerController?.programs!.Sessions.filter { (favList.contains($0.Id)) })! {
            let startTime = Constants.DateFromString(session.Start)
            let start = Constants.DateToDisplayTimeString(startTime)
            if self.favoritesSections.index(forKey: start) == nil {
                self.favoritesTimes.append(startTime)
                self.favoritesSections[start] = Array<String>()
            }
            self.favoritesSections[start]?.append(session.Id)
        }
        self.favoritesTimes.sort()

        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var previewActionItems: [UIPreviewActionItem] {
        return self.previewActions()
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let tableView = previewingContext.sourceView as! UITableView
        guard let indexPath = (tableView.value(forKey: "_highlightedIndexPaths") as! Array<IndexPath>).first else {
            return nil
        }
        let storyboard = UIStoryboard.init(name: "Session", bundle: nil)
        let detailView = storyboard.instantiateViewController(withIdentifier: Constants.INIT_SESSION_DETAIL_VIEW_STORYBOARD_ID) as! SessionDetailViewController
        let time = Constants.DateToDisplayTimeString(self.favoritesTimes[indexPath.section])
        let sessionId = (self.favoritesSections[time]?[indexPath.row])!
        guard let session = self.pagerController?.programs!.GetSession(sessionId) else { return detailView }
        detailView.setSessionData(session)
        let tableCell = tableView.cellForRow(at: indexPath)
        previewingContext.sourceRect = self.view.convert(tableCell!.frame, from: tableView)
        return detailView
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.show(viewControllerToCommit, sender: nil)
    }

    override func show(_ vc: UIViewController, sender: Any?) {
        UIView.animate(withDuration: 0.5, animations: {
            SessionFavoriteTableViewController.headView?.alpha = 0
        }) { finished in
            SessionFavoriteTableViewController.headView?.isHidden = true
            SessionFavoriteTableViewController.headView?.alpha = 1
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.favoritesSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let time = Constants.DateToDisplayTimeString(self.favoritesTimes[section])
        return self.favoritesSections[time]!.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constants.DateToDisplayDateTimeString(self.favoritesTimes[section])
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = AppDelegate.appConfigColor("HighlightedColor")
        view.tintColor = UIColor.colorFromHtmlColor("#ecf5f4")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sessionCellName = "SessionCell"

        var cell = tableView.dequeueReusableCell(withIdentifier: sessionCellName) as? SessionTableViewCell
        if cell == nil {
            tableView.register(UINib.init(nibName: "SessionTableViewCell", bundle: nil), forCellReuseIdentifier: sessionCellName)
            cell = tableView.dequeueReusableCell(withIdentifier: sessionCellName) as? SessionTableViewCell
        }

        let time = Constants.DateToDisplayTimeString(self.favoritesTimes[indexPath.section])
        let sessionId = self.favoritesSections[time]![indexPath.row]
        guard let session = self.pagerController?.programs!.GetSession(sessionId) else { return cell! }
        let endTime = Constants.DateFromString(session.End)
        let sinceEnd = endTime.timeIntervalSince(self.pagerController!.today)

        cell?.selectionStyle = .gray
        cell?.setDisabled(sinceEnd < 0)
        cell?.setSession(session)

        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let time = Constants.DateToDisplayTimeString(self.favoritesTimes[indexPath.section])
        let sessionId = self.favoritesSections[time]?[indexPath.row]
        self.pagerController?.performSegue(withIdentifier: Constants.SESSION_DETAIL_VIEW_STORYBOARD_ID, sender: sessionId)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == Constants.SESSION_DETAIL_VIEW_STORYBOARD_ID {
            guard let detailView = segue.destination as? SessionDetailViewController else { return }
            guard let session = self.pagerController!.programs!.GetSession(sender as! String) else { return }
            detailView.setSessionData(session)
        }
    }
}
