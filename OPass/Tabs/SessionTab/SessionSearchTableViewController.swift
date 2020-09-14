//
//  SessionSearchTableViewController.swift
//  OPass
//
//  Created by FrankWu on 2020/8/6.
//  2020 OPass.
//

import Foundation
import UIKit

class SessionSearchTableViewController: SessionTableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    private static var headView: UIView?
    private var programs: Programs?
    private var sessionInfo: SessionInfo?
    private var searchedList = Array<String>()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let navBar = self.navigationController?.navigationBar else { return }
        navBar.backgroundColor = .clear

        let title = Constants.attributedFontAwesome(ofCode: "fa-search", withSize: 20, inStyle: .solid, forColor: .white)
        let lbTitle = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        lbTitle.textAlignment = .center
        lbTitle.textColor = .white
        lbTitle.attributedText = title
        self.navigationItem.title = ""
        self.navigationItem.titleView = lbTitle

        let navigationBarBounds = navBar.bounds
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: navBar.frame.origin.y + navigationBarBounds.size.height)

        SessionSearchTableViewController.headView = UIView.init(frame: frame)

        guard let headView = SessionSearchTableViewController.headView else { return }
        guard let navController = self.navigationController else { return }
        navBar.superview?.addSubview(headView)
        navBar.superview?.bringSubviewToFront(headView)
        navBar.superview?.bringSubviewToFront(navController.navigationBar)

        let titleFake = Constants.attributedFontAwesome(ofCode: "fa-search", withSize: 20, inStyle: .solid, forColor: .clear)
        let favButtonFake = UIButton.init()
        favButtonFake.setAttributedTitle(titleFake, for: .normal)
        favButtonFake.setTitleColor(.clear, for: .normal)
        favButtonFake.sizeToFit()
        let favoritesButtonFake = UIBarButtonItem.init(customView: favButtonFake)
        self.navigationItem.setRightBarButton(favoritesButtonFake, animated: true)

        self.searchBar.delegate = self
        self.searchBar.placeholder = "Search"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SessionSearchTableViewController.headView?.setGradientColor(from: Constants.appConfigColor.SessionTitleLeftColor, to: Constants.appConfigColor.SessionTitleRightColor, startPoint: CGPoint(x: -0.4, y: 0.5), toPoint: CGPoint(x: 1, y: 0.5))
        SessionSearchTableViewController.headView?.alpha = 0
        SessionSearchTableViewController.headView?.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            SessionSearchTableViewController.headView?.alpha = 1
        }) { _ in
            SessionSearchTableViewController.headView?.alpha = 1
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.programs = self.pagerController?.programs
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SessionSearchTableViewController.headView?.setGradientColor(from: .clear, to: .clear, startPoint: CGPoint(x: -0.4, y: 0.5), toPoint: CGPoint(x: 1, y: 0.5))
    }

    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            SessionSearchTableViewController.headView?.removeFromSuperview()
        }
    }

    override func show(_ vc: UIViewController, sender: Any?) {
        UIView.animate(withDuration: 0.5, animations: {
            SessionSearchTableViewController.headView?.alpha = 0
        }) { _ in
            SessionSearchTableViewController.headView?.isHidden = true
            SessionSearchTableViewController.headView?.alpha = 1
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchText.trim().lowercased()

        // reset search result
        self.searchedList.removeAll()

        // Can set minimum string length > 0, especially English
        if text.count > 0 {
            // Find in Sessions
            for session in self.programs?.Sessions ?? [] {
                guard let sessionInfo = self.programs?.GetSession(session.Id) else { continue }

                // supported: title, description, speakers, room, type, language, tags
                // not yet: date
                var searchableFields = [
                    sessionInfo["title"].lowercased(),
                    //sessionInfo["description"].lowercased(),
                    sessionInfo.Room?.lowercased() ?? "",
                    sessionInfo.Type?.lowercased() ?? "",
                    sessionInfo.Language.lowercased(),
                ].filter({ s -> Bool in
                    return s.count > 0
                })
                searchableFields += sessionInfo.Speakers.map({ s -> String in
                    return s["name"].lowercased()
                })
                searchableFields += sessionInfo.Tags.map({ t -> String in
                    return t.Name.lowercased()
                })

                for s in searchableFields {
                    if s.contains(text) {
                        self.searchedList.append(sessionInfo.Id)
                        break
                    }
                }
            }
        }

        self.updateResult()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchedList.removeAll()
        self.updateResult()
    }

    func searchBarSearchButtonClicked() {
        self.searchBar.endEditing(true)
    }

    func updateResult() {
        self.sessionTimes.removeAll()
        self.sessionSections.removeAll()
        guard let pager = self.pagerController else { return }
        guard let programs = pager.programs else { return }
        self.parseSectionsAndTime(programs, self.searchedList)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == Constants.SESSION_DETAIL_VIEW_STORYBOARD_ID {
            guard let detailView = segue.destination as? SessionDetailViewController else { return }
            guard let session = self.pagerController?.programs?.GetSession(sender as? String ?? "") else { return }
            detailView.setSessionData(session)
        }
    }

}
