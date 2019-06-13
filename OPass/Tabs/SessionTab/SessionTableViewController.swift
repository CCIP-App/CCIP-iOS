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
    var programTimes = Array<Date>()
    var programSections = Dictionary<String, Array<String>>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForceTouch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.programTimes.removeAll()
        self.programSections.removeAll()
        for session in (self.pagerController?.programs!.Sessions.filter { (self.sessionIds?.contains($0.Id))! })! {
            let startTime = Constants.DateFromString(session.Start)
            let start = Constants.DateToDisplayTimeString(startTime)
            if self.programSections.index(forKey: start) == nil {
                self.programTimes.append(startTime)
                self.programSections[start] = Array<String>()
            }
            self.programSections[start]?.append(session.Id)
        }
        self.programTimes.sort()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        let time = Constants.DateToDisplayTimeString(self.programTimes[indexPath.section])
        let sessionId = (self.programSections[time]?[indexPath.row])!
        guard let session = self.pagerController?.programs!.GetSession(sessionId) else { return detailView }
        detailView.setSessionData(session)
        let tableCell = tableView.cellForRow(at: indexPath)
        previewingContext.sourceRect = self.view.convert(tableCell!.frame, from: tableView)
        return detailView
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.show(viewControllerToCommit, sender: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.programSections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constants.DateToDisplayTimeString(self.programTimes[section])
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = AppDelegate.appConfigColor("SessionSectionTitleTextColor")
        view.tintColor = AppDelegate.appConfigColor("SessionSectionTitleBackgroundColor")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let time = Constants.DateToDisplayTimeString(self.programTimes[section])
        return self.programSections[time]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sessionCellName = "SessionCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: sessionCellName) as? SessionTableViewCell
        if cell == nil {
            tableView.register(UINib.init(nibName: "SessionTableViewCell", bundle: nil), forCellReuseIdentifier: sessionCellName)
            cell = tableView.dequeueReusableCell(withIdentifier: sessionCellName) as? SessionTableViewCell
        }

        let time = Constants.DateToDisplayTimeString(self.programTimes[indexPath.section])
        let sessionId = (self.programSections[time]?[indexPath.row])!
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
        let time = Constants.DateToDisplayTimeString(self.programTimes[indexPath.section])
        let sessionId = self.programSections[time]?[indexPath.row]
        self.pagerController?.performSegue(withIdentifier: Constants.SESSION_DETAIL_VIEW_STORYBOARD_ID, sender: sessionId)
    }
}
