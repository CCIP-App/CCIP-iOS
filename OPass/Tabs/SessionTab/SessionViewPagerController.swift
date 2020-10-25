//
//  SessionViewPagerController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/12.
//  2019 OPass.
//

import Foundation
import UIKit
import MBProgressHUD

class SessionViewPagerController: ViewPagerController, ViewPagerDataSource, ViewPagerDelegate {
    private var _endpointKey: String? = nil
    private var endpointKey: String? {
        get {
            if self._endpointKey != nil {
                return self._endpointKey
            }
            if let svc = self.parent as? SessionViewController {
                self._endpointKey = svc.endpointKey
            }
            return self._endpointKey
        }
    }
    internal var selectedSection = Date.init(timeIntervalSince1970: 0)
    internal var segmentsTextArray = Array<String>()
    public var today: Date {
        return Date.init()
    }
    internal var firstLoad: Bool = true
    internal var programs: Programs?
    private var progress: MBProgressHUD?

    private func initProgramsData() {
        let defaults: [String: Any] = [
            Constants.SESSION_FAV_KEY(self.endpointKey): [Any](),
            Constants.SESSION_CACHE_KEY(self.endpointKey): [String: Any]()
        ]
        let userDefault = UserDefaults.standard
        userDefault.register(defaults: defaults)
        userDefault.synchronize()
    }

    private func loadProgramsData() {
        let userDefault = UserDefaults.standard
        // ugly convension for crash prevent
        guard let programsObj = userDefault.object(forKey: Constants.SESSION_CACHE_KEY(self.endpointKey)) as? Data else {
            self.programs = nil
            return
        }
        guard let prog = try? PropertyListDecoder().decode(Programs.self, from: programsObj) else { return }
        self.programs = prog
        self.programs?._regenSessions()
        self.setSessionDate()
    }

    private func saveProgramsData() {
        let userDefault = UserDefaults.standard
        self.programs?._sessions.removeAll()
        let programsData = try? PropertyListEncoder().encode(self.programs)
        self.programs?._regenSessions()
        userDefault.set(programsData, forKey: Constants.SESSION_CACHE_KEY(self.endpointKey))
        userDefault.synchronize()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        self.view.backgroundColor = .clear

        // Do any additional setup after loading the view.
        self.progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.progress?.mode = .indeterminate
        self.initProgramsData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.firstLoad {
            self.loadProgramsData()
            self.refreshData()
        }
    }

    func refreshData(_ onSuccess: (() -> Void)? = nil) {
        OPassAPI.GetSessionData(OPassAPI.currentEvent, self.endpointKey ?? String(describing: OPassKnownFeatures.Schedule)) { (success, data, err) in
            if (success) {
                self.programs = data as? Programs
                self.setSessionDate()
                self.saveProgramsData()

                onSuccess?()
            } else {
                UIAlertController.alertOfTitle("Error", withMessage: err.localizedDescription, cancelButtonText: "Okay", cancelStyle: .destructive, cancelAction: nil).showAlert {
                    UIImpactFeedback.triggerFeedback(.impactFeedbackHeavy)
                }
                NSLog("Error: \(err.localizedDescription)")
                self.loadProgramsData()
            }
        }
    }

    func setSessionDate() {
        self.selectedSection = Date.init(timeIntervalSince1970: 0)
        self.segmentsTextArray.removeAll()
        var preferredDateInterval: TimeInterval = TimeInterval(CGFloat.greatestFiniteMagnitude)
        guard let programs = self.programs else { return }
        for session in programs.Sessions {
            let startTime = Constants.DateFromString(session.Start)
            let endTime = Constants.DateFromString(session.End)
            let timeDate = Constants.DateToDisplayDateString(startTime)
            self.segmentsTextArray += [ timeDate ]
            let sinceNow = startTime.timeIntervalSince(self.today)
            let sinceEnd = self.today.timeIntervalSince(endTime)
            if sinceEnd >= 0 {
                preferredDateInterval = Constants.NEAR_ZERO(sinceNow, preferredDateInterval)
            }
        }
        self.segmentsTextArray = Array(Set(self.segmentsTextArray.map{ $0.lowercased() })).sorted()
        self.reloadData()
        if self.firstLoad {
            self.selectedSection = Date.init(timeInterval: preferredDateInterval, since: self.today)
            let selectedIndex = self.segmentsTextArray.firstIndex(of: Constants.DateToDisplayDateString(self.selectedSection))
            self.selectTab(at: UInt(selectedIndex ?? 0))
            self.firstLoad = false
        }
        if self.progress != nil {
            self.progress?.hide(animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ViewPagerDelegate

    //Returns the number of tabs that will be present in ViewPager.
    func numberOfTabs(forViewPager viewPager: ViewPagerController?) -> UInt {
        return UInt(self.segmentsTextArray.count)
    }

    //Returns the view that will be shown as tab. Create a UIView object (or any UIView subclass object) and give it to ViewPager and it will use it as tab view.
    func viewPager(_ viewPager: ViewPagerController?, viewForTabAt index: UInt) -> UIView! {
        let label = UILabel.init()
        label.text = "DAY \(self.segmentsTextArray[Int(index)])"
        label.textColor = Constants.appConfigColor.SessionDateTitleTextColor
        label.font = UIFont.init(name: "PingFangTC-Medium", size: 14)
        label.sizeToFit()
        return label
    }

    // MARK: - ViewPagerDataSource

    //Returns the view controller that will be shown as content. Create a UIViewController object (or any UIViewController subclass object) and give it to ViewPager and it will use the view property of the view controller as content view.
    //Alternatively, you can implement - viewPager:contentViewForTabAtIndex: method and return a UIView object (or any UIView subclass object) and ViewPager will use it as content view.
    //The - viewPager:contentViewControllerForTabAtIndex: and - viewPager:contentViewForTabAtIndex: dataSource methods are both defined optional. But, you should implement at least one of them! They are defined as optional to provide you an option.
    //All delegate methods are optional.
    func viewPager(_ viewPager: ViewPagerController?, contentViewControllerForTabAt index: UInt) -> UIViewController! {
        let vc = SessionTableViewController.init()
        vc.sessionDate = self.segmentsTextArray[Int(index)]
        vc.pagerController = self
        return vc
    }

    //ViewPager will alert your delegate object via - viewPager:didChangeTabToIndex: method, so that you can do something useful.
    func viewPager(_ viewPager: ViewPagerController?, didChangeTabTo index: UInt) {
        // Do something useful
    }

    //You can change ViewPager's options via viewPager:valueForOption:withDefault: delegate method. Just return the desired value for the given option. You don't have to return a value for every option. Only return values for the interested options and ViewPager will use the default values for the rest. Available options are defined in the ViewPagerController.h file and described below.
    func viewPager(_ viewPager: ViewPagerController?, valueFor option: ViewPagerOption, withDefault value: CGFloat) -> CGFloat {
        switch (option) {
        case ViewPagerOption.startFromSecondTab:
            return 0.0
        case ViewPagerOption.centerCurrentTab:
            return 0.0
        case ViewPagerOption.tabLocation:
            return 1.0
//        case ViewPagerOption.tabHeight:
//            return 49.0
//        case ViewPagerOption.tabOffset:
//            return 36.0
        case ViewPagerOption.tabDisableTopLine:
            return 1.0
        case ViewPagerOption.tabDisableBottomLine:
            return 1.0
        case ViewPagerOption.tabNormalLineWidth:
            return 5.0
        case ViewPagerOption.tabSelectedLineWidth:
            return 5.0
        case ViewPagerOption.tabWidth:
            return UIScreen.main.bounds.size.width / CGFloat(self.segmentsTextArray.count)
        case ViewPagerOption.fixFormerTabsPositions:
            return 0.0
        case ViewPagerOption.fixLatterTabsPositions:
            return 0.0
        default:
            return value
        }
    }

    func viewPager(_ viewPager: ViewPagerController?, colorFor component: ViewPagerComponent, withDefault color: UIColor?) -> UIColor! {
        switch (component) {
        case ViewPagerComponent.indicator:
            return Constants.appConfigColor.SessionDateIndicatorColor
        case ViewPagerComponent.tabsView:
            return UIColor.clear
        case ViewPagerComponent.content:
            return UIColor.white
        default:
            return color
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == Constants.SESSION_DETAIL_VIEW_STORYBOARD_ID {
            guard let sender = sender as? String else { return }
            guard let detailView = segue.destination as? SessionDetailViewController else { return }
            guard let programs = self.programs else { return }
            guard let session = programs.GetSession(sender) else { return }
            detailView.setSessionData(session)
        }
    }
}
