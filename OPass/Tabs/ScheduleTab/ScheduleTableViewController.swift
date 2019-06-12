//
//  ScheduleTableViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/13.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import UIKit

class ScheduleTableViewController: UITableViewController, UIViewControllerPreviewingDelegate, ScheduleFavoriteDelegate {
    func getID(_ program: NSDictionary) -> String {
        return ""
    }

    func actionFavorite(_ scheduleId: String) {

    }

    func hasFavorite(_ scheduleId: String) -> Bool {
        return false
    }

    //- (void)actionFavorite:(NSString *)scheduleId {
    //    NSDictionary *favProgram = @{};
    //    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //    NSObject *favObj = [userDefault valueForKey:Constants.FAV_KEY];
    //    NSArray *favoriteArray = [favObj isKindOfClass:[NSData class]] ? [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)favObj] : favObj;
    //    NSMutableArray *favorites = [NSMutableArray arrayWithArray:favoriteArray];
    //    for (NSDate *time in self.programTimes) {
    //        NSString *timeString = [Constants DateToDisplayTimeString:time];
    //        for (NSDictionary *program in [self.programSections objectForKey:timeString]) {
    //            if (program != nil && [[self getID:program] isEqualToString:scheduleId]) {
    //                favProgram = program;
    //                break;
    //            }
    //        }
    //        if ([[favProgram allKeys] count] > 0) {
    //            break;
    //        }
    //    }
    //    BOOL hasFavorite = [self hasFavorite:scheduleId];
    //    if (!hasFavorite) {
    //        [favorites addObject:favProgram];
    //    } else {
    //        [favorites removeObject:favProgram];
    //    }
    //    NSData *favData = [NSKeyedArchiver archivedDataWithRootObject:favorites];
    //    [userDefault setValue:favData
    //                   forKey:Constants.FAV_KEY];
    //    [userDefault synchronize];
    //    [self.tableView reloadData];
    ////    [OPassAPI RegisteringFavoriteScheduleForEvent:[Constants EventId]
    ////                                        withToken:[Constants AccessToken]
    ////                                       toSchedule:scheduleId
    ////                                        isDisable:NO
    ////                                       completion:^(BOOL success, id _Nullable obj, NSError * _Nonnull error) {
    ////                                           NSLog(@"%@", obj);
    ////                                       }];
    //}
    //
    //- (BOOL)hasFavorite:(NSString *)scheduleId {
    //    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //    // ugly convension for crash prevent
    //    NSObject *favObj = [userDefault valueForKey:Constants.FAV_KEY];
    //    NSArray *favorites = [favObj isKindOfClass:[NSData class]] ? [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)favObj] : favObj;
    //    for (NSDictionary *program in favorites) {
    //        if ([[self getID:program] isEqualToString:scheduleId]) {
    //            return YES;
    //        }
    //    }
    //    return NO;
    //}

    public var pagerController: ScheduleViewPagerController?
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
        let storyboard = UIStoryboard.init(name: "Schedule", bundle: nil)
        let detailView = storyboard.instantiateViewController(withIdentifier: Constants.INIT_SCHEDULE_DETAIL_VIEW_STORYBOARD_ID) as! ScheduleDetailViewController
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
        return 80
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.programSections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constants.DateToDisplayTimeString(self.programTimes[section])
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = AppDelegate.appConfigColor("ScheduleSectionTitleTextColor")
        view.tintColor = AppDelegate.appConfigColor("ScheduleSectionTitleBackgroundColor")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let time = Constants.DateToDisplayTimeString(self.programTimes[section])
        return self.programSections[time]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let scheduleCellName = "ScheduleCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: scheduleCellName) as? ScheduleTableViewCell
        if cell == nil {
            tableView.register(UINib.init(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: scheduleCellName)
            cell = tableView.dequeueReusableCell(withIdentifier: scheduleCellName) as? ScheduleTableViewCell
        }

        let time = Constants.DateToDisplayTimeString(self.programTimes[indexPath.section])
        let sessionId = (self.programSections[time]?[indexPath.row])!
        guard let session = self.pagerController?.programs!.GetSession(sessionId) else { return cell! }
        let endTime = Constants.DateFromString(session.End)
        let sinceEnd = endTime.timeIntervalSince(self.pagerController!.today)

        cell?.selectionStyle = .gray
        cell?.setDisabled(sinceEnd < 0)
        cell?.setDelegate(self)
        cell?.setSession(session)

        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let time = Constants.DateToDisplayTimeString(self.programTimes[indexPath.section])
        let sessionId = self.programSections[time]?[indexPath.row]
        self.pagerController?.performSegue(withIdentifier: Constants.SCHEDULE_DETAIL_VIEW_STORYBOARD_ID, sender: sessionId)
    }


}
