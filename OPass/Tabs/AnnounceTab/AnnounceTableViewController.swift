//
//  AnnounceTableViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/3/16.
//  2019 OPass.
//

import Foundation
import UIKit
import SwiftDate
import SwiftyJSON
import UIView_FDCollapsibleConstraints
import UITableView_FDTemplateLayoutCell

class AnnounceTableViewController: UIViewController, InvalidNetworkRetryDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet public var announceTableView: UITableView!
    @IBOutlet public var ivNoAnnouncement: UIImageView!
    @IBOutlet public var lbNoAnnouncement: UILabel!
    public var announceJsonArray: [AnnouncementInfo] = [AnnouncementInfo]()

    private var refreshControl: UIRefreshControl = UIRefreshControl.init()
    private var loaded: Bool = false
    @objc public var controllerTopStart: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.announceTableView.separatorColor = UIColor.clear
        self.announceJsonArray = [AnnouncementInfo]()
        self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.announceTableView.addSubview(self.refreshControl)

        self.navigationItem.title = NSLocalizedString("AnnouncementTitle", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage.init()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 239)
        let headView = UIView.init(frame: frame)
        headView.setGradientColor(
            from: Constants.appConfigColor.AnnouncementTitleLeftColor,
            to: Constants.appConfigColor.AnnouncementTitleRightColor,
            startPoint: CGPoint(x: -0.4, y: -0.5),
            toPoint: CGPoint(x: 1, y: 0.5)
        )
        self.view.addSubview(headView)
        self.view.sendSubviewToBack(headView)

        let noAnnouncementText = NSLocalizedString("NoAnnouncementText", comment: "")
        let attributedNoAnnouncementText = NSMutableAttributedString.init(string: noAnnouncementText)
        attributedNoAnnouncementText.addAttributes(
            [ NSAttributedString.Key.kern: 5.0 ],
            range: NSRange(location: 0, length: noAnnouncementText.count)
        )
        self.lbNoAnnouncement.attributedText = attributedNoAnnouncementText
        self.lbNoAnnouncement.textColor = Constants.appConfigColor.AnnouncementNoContentTextColor

        Constants.SendFib("AnnounceTableViewController")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navController = self.navigationController {
            self.controllerTopStart = navController.navigationBar.frame.size.height
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refresh()
    }

    @objc func refresh() {
        self.loaded = false
        self.refreshControl.beginRefreshing()
        OPassAPI.GetAnnouncement(Constants.EventId) { (success: Bool, data: Any?, _) in
            if data != nil {
                if success {
                    self.loaded = true
                    if let data = data as? [AnnouncementInfo] {
                        self.announceJsonArray = data
                    }
                    self.announceTableView.reloadData()
                } else {
                    if data != nil {
                        self.performSegue(
                            withIdentifier: "ShowInvalidNetworkMsg",
                            sender: NSLocalizedString("Networking_Broken", comment: "")
                        )
                    } else {
                        self.loaded = true
                        self.announceJsonArray = [AnnouncementInfo]()
                        self.announceTableView.reloadData()
                    }
                }
            }
            self.refreshControl.endRefreshing()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if destination.isMember(of: InvalidNetworkMessageViewController.self) {
            if let inmvc = destination as? InvalidNetworkMessageViewController {
                if let sender = sender as? String {
                    inmvc.message = sender
                    inmvc.delegate = self
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewControllerDelegate

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.announceJsonArray.count
        if self.loaded {
            let NoAnnouncement = count == 0
            self.ivNoAnnouncement.isHidden = !NoAnnouncement
            self.lbNoAnnouncement.isHidden = !NoAnnouncement
        } else {
            self.ivNoAnnouncement.isHidden = true
            self.lbNoAnnouncement.isHidden = true
        }
        return count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AnnounceCell", for: indexPath) as? AnnounceTableViewCell else { return tableView.dequeueReusableCell(withIdentifier: "AnnounceCell", for: indexPath) }
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.fd_heightForCell(withIdentifier: "AnnounceCell", configuration: { (cell: Any) in
            if let cell = cell as? AnnounceTableViewCell {
                self.configureCell(cell, atIndexPath: indexPath)
            }
        })
    }

    func configureCell(_ cell: AnnounceTableViewCell, atIndexPath indexPath: IndexPath) {
        cell.fd_enforceFrameLayout = false // Enable to use "-sizeThatFits:"
        cell.selectionStyle = .none
        cell.clipsToBounds = false
        cell.backgroundColor = UIColor.clear
        cell.layer.zPosition = CGFloat(indexPath.row)
        guard let vwContent = cell.vwContent else { return }
        vwContent.layer.cornerRadius = 5.0
        vwContent.layer.masksToBounds = true

        guard let vwShadowContent = cell.vwShadowContent else { return }
        vwShadowContent.layer.cornerRadius = 5.0
        vwShadowContent.layer.masksToBounds = false
        vwShadowContent.layer.shadowRadius = 50.0
        vwShadowContent.layer.shadowOffset = CGSize(width: 0, height: 50)
        vwShadowContent.layer.shadowColor = UIColor.black.cgColor
        vwShadowContent.layer.shadowOpacity = 0.1

        let announce = self.announceJsonArray[indexPath.row]
        guard let language = Bundle.main.preferredLocalizations.first else { return }

        cell.lbMessage.text = (language.contains("zh") ? announce.MsgZh : announce.MsgEn) + "\n"
        let uri = announce.URI
        let hasURL = uri != ""
        // cell.accessoryType = hasURL ? .disclosureIndicator : .none
        let datetime = announce.DateTime
        let strDate = Constants.DateToDisplayDateAndTimeString(datetime)
        cell.lbMessageTime.text = strDate
        cell.lbMessageTime.textColor = Constants.appConfigColor.AnnouncementSectionTitleTextColor
        cell.vwMessageTime.backgroundColor = Constants.appConfigColor.AnnouncementSectionTitleBackgroundColor

        if hasURL {
            cell.lbURL.text = uri
            if let foregroundColor = cell.lbIconOfURL.textColor {
            let titleAttribute: [NSAttributedString.Key: Any] = [
                    .font: Constants.fontOfAwesome(withSize: 20, inStyle: .solid),
                    .foregroundColor: foregroundColor,
                ]
                if let str = Constants.fontAwesome(code: "fa-external-link-alt") {
                    let title = NSAttributedString.init(
                        string: str,
                        attributes: titleAttribute
                    )
                    cell.lbIconOfURL.attributedText = title
                }
            }
        } else {
            cell.lbURL.text = ""
            cell.lbIconOfURL.attributedText = nil
        }
        cell.vwDashedLine.addDashedLine(Constants.appConfigColor.AnnouncementDashedLineColor)
        cell.vwURL.fd_collapsed = !hasURL
    }

    // MARK: - Table view delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let announce = self.announceJsonArray[indexPath.row]
        let uri = announce.URI

        if uri == "" {
            return
        }

        Constants.OpenInAppSafari(forPath: uri)

        Constants.SendFib("AnnounceTableView", WithEvents: ["URL": uri])
    }

    /*
     // Override to support conditional editing of the table view.
     - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
     // Return NO if you do not want the specified item to be editable.
     return YES;
     }
     */

    /*
     // Override to support editing the table view.
     - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
     // Delete the row from the data source
     [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
     } else if (editingStyle == UITableViewCellEditingStyleInsert) {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */

    /*
     // Override to support rearranging the table view.
     - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
     }
     */

    /*
     // Override to support conditional rearranging of the table view.
     - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
     // Return NO if you do not want the item to be re-orderable.
     return YES;
     }
     */

    /*
     #pragma mark - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
}
