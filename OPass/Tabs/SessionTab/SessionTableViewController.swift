//
//  SessionTableViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/13.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import UIKit

class SessionTableViewController: UITableViewController, UIViewControllerPreviewingDelegate {
    public var pagerController: SessionViewPagerController?
    public var sessionIds: Array<String>?
    var sessionTimes = Array<Date>()
    var sessionSections = Dictionary<String, Array<String>>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForceTouch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // only empty is specified for display favorite list
        if self.sessionIds != nil {
            self.sessionTimes.removeAll()
            self.sessionSections.removeAll()
            for session in (self.pagerController?.programs!.Sessions.filter { (self.sessionIds?.contains($0.Id))! })! {
                let startTime = Constants.DateFromString(session.Start)
                let start = Constants.DateToDisplayTimeString(startTime)
                if self.sessionSections.index(forKey: start) == nil {
                    self.sessionTimes.append(startTime)
                    self.sessionSections[start] = Array<String>()
                }
                self.sessionSections[start]?.append(session.Id)
            }
            self.sessionTimes.sort()
        } else {
            self.parseFavorites()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {[weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func parseFavorites() {
        self.sessionTimes.removeAll()
        self.sessionSections.removeAll()
        guard let token = Constants.accessToken else { return }
        let favList = OPassAPI.GetFavoritesList(OPassAPI.eventInfo!.EventId, token)
        for session in (self.pagerController?.programs!.Sessions.filter { (favList.contains($0.Id)) })! {
            let startTime = Constants.DateFromString(session.Start)
            let start = Constants.DateToDisplayTimeString(startTime)
            if self.sessionSections.index(forKey: start) == nil {
                self.sessionTimes.append(startTime)
                self.sessionSections[start] = Array<String>()
            }
            self.sessionSections[start]?.append(session.Id)
        }
        self.sessionTimes.sort()

        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {[weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
        }
    }

    // MARK: - Peek & Pop Preview

    override var previewActionItems: [UIPreviewActionItem] {
        return self.previewActions()
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.show(viewControllerToCommit, sender: nil)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let tableView = previewingContext.sourceView as! UITableView
        guard let indexPath = (tableView.value(forKey: "_highlightedIndexPaths") as! Array<IndexPath>).first else {
            return nil
        }
        let storyboard = UIStoryboard.init(name: "Session", bundle: nil)
        let detailView = storyboard.instantiateViewController(withIdentifier: Constants.INIT_SESSION_DETAIL_VIEW_STORYBOARD_ID) as! SessionDetailViewController
        let time = Constants.DateToDisplayTimeString(self.sessionTimes[indexPath.section])
        let sessionId = (self.sessionSections[time]?[indexPath.row])!
        guard let session = self.pagerController?.programs!.GetSession(sessionId) else { return detailView }
        detailView.setSessionData(session)
        let tableCell = tableView.cellForRow(at: indexPath)
        previewingContext.sourceRect = self.view.convert(tableCell!.frame, from: tableView)
        return detailView
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sessionSections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let time = self.sessionTimes[section]
        if self.className != SessionTableViewController.className {
            return Constants.DateToDisplayDateTimeString(time)
        } else {
            return Constants.DateToDisplayTimeString(time)
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = Constants.appConfigColor("SessionSectionTitleTextColor")
        view.tintColor = Constants.appConfigColor("SessionSectionTitleBackgroundColor")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let time = Constants.DateToDisplayTimeString(self.sessionTimes[section])
        return self.sessionSections[time]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sessionCellName = "SessionCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: sessionCellName) as? SessionTableViewCell
        if cell == nil {
            tableView.register(UINib.init(nibName: "SessionTableViewCell", bundle: nil), forCellReuseIdentifier: sessionCellName)
            cell = tableView.dequeueReusableCell(withIdentifier: sessionCellName) as? SessionTableViewCell
        }

        let time = Constants.DateToDisplayTimeString(self.sessionTimes[indexPath.section])
        let sessionId = (self.sessionSections[time]?[indexPath.row])!
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
        let time = Constants.DateToDisplayTimeString(self.sessionTimes[indexPath.section])
        let sessionId = self.sessionSections[time]?[indexPath.row]
        self.pagerController?.performSegue(withIdentifier: Constants.SESSION_DETAIL_VIEW_STORYBOARD_ID, sender: sessionId)
    }
}
