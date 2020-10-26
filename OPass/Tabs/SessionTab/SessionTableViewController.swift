//
//  SessionTableViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/13.
//  2019 OPass.
//

import Foundation
import UIKit

class SessionTableViewController: UITableViewController, UIViewControllerPreviewingDelegate, UISearchBarDelegate {
    public var pagerController: SessionViewPagerController?
    public var sessionDate: String?
    var sessionTimes = Array<Date>()
    var sessionSections = Dictionary<String, Array<String>>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForceTouch()
        let refreshControl = UIRefreshControl()
        self.tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // only empty is specified for display favorite list
        if (self.sessionDate != nil) {
            guard let pager = self.pagerController else { return }
            guard let programs = pager.programs else { return }
            guard let sessionDate = self.sessionDate else { return }
            let sessionIds = programs.GetSessionIds(byDateString: sessionDate)
            self.sessionTimes.removeAll()
            self.sessionSections.removeAll()
            for session in (programs.Sessions.filter { (sessionIds.contains($0.Id)) }) {
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
            switch self {
            case is SessionFavoriteTableViewController:
                self.parseFavorites()
                break
            case is SessionSearchTableViewController:
                self.parseSearch()
                break
            default:
                break
            }
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
        guard let eventInfo = OPassAPI.eventInfo else { return }
        let favList = OPassAPI.GetFavoritesList(eventInfo.EventId, token)
        guard let pager = self.pagerController else { return }
        guard let programs = pager.programs else { return }
        self.parseSectionsAndTime(programs, favList)
    }

    func parseSectionsAndTime(_ programs: Programs, _ list: [String]) {
        for session in (programs.Sessions.filter { (list.contains($0.Id)) }) {
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

    func parseSearch() {
        // no-op
    }

    // MARK: - Peek & Pop Preview

    override var previewActionItems: [UIPreviewActionItem] {
        return self.previewActions()
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.show(viewControllerToCommit, sender: nil)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let tableView = previewingContext.sourceView as? UITableView {
            guard let indexPath = (tableView.value(forKey: "_highlightedIndexPaths") as? Array<IndexPath>)?.first else {
                return nil
            }
            let storyboard = UIStoryboard.init(name: "Session", bundle: nil)
            guard let detailView = storyboard.instantiateViewController(withIdentifier: Constants.INIT_SESSION_DETAIL_VIEW_STORYBOARD_ID) as? SessionDetailViewController else { return nil }
            let time = Constants.DateToDisplayTimeString(self.sessionTimes[indexPath.section])
            guard let sessionId = self.sessionSections[time]?[indexPath.row] else { return detailView }
            guard let programs = self.pagerController?.programs else { return detailView }
            guard let session = programs.GetSession(sessionId) else { return detailView }
            detailView.setSessionData(session)
            guard let tableCell = tableView.cellForRow(at: indexPath) else { return detailView }
            previewingContext.sourceRect = self.view.convert(tableCell.frame, from: tableView)
            return detailView
        }
        return nil
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
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = Constants.appConfigColor.SessionSectionTitleTextColor
        view.tintColor = Constants.appConfigColor.SessionSectionTitleBackgroundColor
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let time = Constants.DateToDisplayTimeString(self.sessionTimes[section])
        guard let sessionSections = self.sessionSections[time] else { return 0 }
        return sessionSections.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sessionCellName = "SessionCell"
        let nilCell = UITableViewCell.init()
        var cell = tableView.dequeueReusableCell(withIdentifier: sessionCellName) as? SessionTableViewCell
        if cell == nil {
            tableView.register(UINib.init(nibName: "SessionTableViewCell", bundle: nil), forCellReuseIdentifier: sessionCellName)
            cell = tableView.dequeueReusableCell(withIdentifier: sessionCellName) as? SessionTableViewCell
        }
        guard let pager = self.pagerController else { return nilCell }
        let time = Constants.DateToDisplayTimeString(self.sessionTimes[indexPath.section])
        guard let programs = pager.programs else { return nilCell }
        guard let sessionId = self.sessionSections[time]?[indexPath.row] else { return nilCell }
        guard let session = programs.GetSession(sessionId) else { return nilCell }
        let endTime = Constants.DateFromString(session.End)
        let sinceEnd = endTime.timeIntervalSince(pager.today)

        cell?.selectionStyle = .gray
        cell?.setDisabled(sinceEnd < 0)
        cell?.setSession(session)

        return cell ?? nilCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let time = Constants.DateToDisplayTimeString(self.sessionTimes[indexPath.section])
        let sessionId = self.sessionSections[time]?[indexPath.row]
        self.pagerController?.performSegue(withIdentifier: Constants.SESSION_DETAIL_VIEW_STORYBOARD_ID, sender: sessionId)
    }

    @objc private func refreshTableView() {
        self.pagerController?.refreshData() {[weak self] in
            let refreshControl = self?.tableView.subviews.first(where: { $0 is UIRefreshControl }) as? UIRefreshControl
            refreshControl?.endRefreshing()
            self?.tableView.reloadData()
        }
    }
}
