//
//  MoreTableViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/2/9.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox
import AFNetworking
import FontAwesome_swift
import Nuke

let ACKNOWLEDGEMENTS = "Acknowledgements"

class MoreTableViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var moreTableView: UITableView?
    var shimmeringLogoView: FBShimmeringView = FBShimmeringView.init(frame: CGRect(x: 0, y: 0, width: 500, height: 50))
    var userInfo: ScenarioStatus?
    var moreItems: NSArray?
    var switchEventButton: UIBarButtonItem?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        let cell = sender as! UITableViewCell
        let title = cell.textLabel?.text
        Constants.SendFib("MoreTableView", WithEvents: [ "MoreTitle": title ])
        destination.title = title
        cell.setSelected(false, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // set logo on nav title
        self.shimmeringLogoView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(navSingleTap))
        tapGesture.numberOfTapsRequired = 1
        self.shimmeringLogoView.addGestureRecognizer(tapGesture)
        self.navigationItem.titleView = self.shimmeringLogoView

        let nvBar = self.navigationController?.navigationBar
        nvBar!.setBackgroundImage(UIImage.init(), for: .default)
        nvBar!.shadowImage = UIImage.init()
        nvBar!.backgroundColor = UIColor.clear
        nvBar!.isTranslucent = false
        let frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: UIApplication.shared.statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height)
        let headView = UIView.init(frame: frame)
        headView.setGradientColor(from: Constants.appConfigColor("MoreTitleLeftColor"), to: Constants.appConfigColor("MoreTitleRightColor"), startPoint: CGPoint(x: -0.4, y: 0.5), toPoint: CGPoint(x: 1, y: 0.5))
        let naviBackImg = headView.layer.sublayers?.last?.toImage()
        nvBar?.setBackgroundImage(naviBackImg, for: .default)

        Constants.SendFib("MoreTableViewController")

        if self.switchEventButton == nil {
            let attribute = [
                NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 20, style: .solid)
            ]
            self.switchEventButton = UIBarButtonItem.init(title: "", style: .plain, target: self, action: #selector(CallSwitchEventView))
            self.switchEventButton!.setTitleTextAttributes(attribute, for: .normal)
            self.switchEventButton!.title = String.fontAwesomeIcon(code: "fa-sign-out-alt")
        }

        self.navigationItem.rightBarButtonItem = self.switchEventButton
        
        let emptyButton = UIBarButtonItem.init(title: "　", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = emptyButton;
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Constants.LoadDevLogoTo(view: self.shimmeringLogoView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.userInfo = OPassAPI.userInfo
        let features = OPassAPI.eventInfo?.Features.map { feature -> [Any?] in
            switch OPassKnownFeatures(rawValue: feature.Feature) {
            case Optional(.Puzzle):
                return ["Puzzle", feature]
            case Optional(.FastPass):
                return ["Ticket", feature]
            case Optional(.Telegram):
                return ["Telegram", feature]
            case Optional(.Venue):
                return ["VenueWeb", feature]
            case Optional(.Staffs):
                return ["StaffsWeb", feature]
            case Optional(.Sponsors):
                return ["SponsorsWeb", feature]
            case Optional(.Partners):
                return ["PartnersWeb", feature]
            case Optional(.WebView):
                return ["MoreWeb", feature]
            default:
                return ["", nil]
            }
        }
        self.moreItems = ((features ?? [["", nil]]) + [
            [ACKNOWLEDGEMENTS, nil]
        ]).filter { ($0![0] as! String).count > 0 } as NSArray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func CallSwitchEventView() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func navSingleTap() {
        //NSLog(@"navSingleTap");
        self.handleNavTapTimes()
    }

    func handleNavTapTimes() {
        struct tap {
            static var tapTimes: Int = 0
            static var oldTapTime: Date?
            static var newTapTime: Date?
        }

        tap.newTapTime = Date.init()
        if (tap.oldTapTime == nil) {
            tap.oldTapTime = tap.newTapTime
        }

        if (tap.newTapTime!.timeIntervalSince(tap.oldTapTime!) <= 0.25) {
            tap.tapTimes += 1
            if (tap.tapTimes >= 10) {
                NSLog("--  Success tap 10 times  --")
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                if !Constants.isDevMode {
                    NSLog("-- Enable DEV_MODE --")
                    Constants.isDevMode = true
                } else {
                    NSLog("-- Disable DEV_MODE --")
                    Constants.isDevMode = false
                }
                Constants.LoadDevLogoTo(view: self.shimmeringLogoView)
                tap.tapTimes = 1
            }
        } else {
            NSLog("--  Failed, just tap %2d times  --", tap.tapTimes)
            NSLog("-- Failed to trigger DEV_MODE --")
            tap.tapTimes = 1
        }
        tap.oldTapTime = tap.newTapTime
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.moreTableView?.frame.size.height)! / CGFloat(self.moreItems!.count + 1)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.moreItems!.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section:NSInteger) -> String? {
        return (self.userInfo?.UserId.count ?? 0) > 0 ? String(format: NSLocalizedString("Hi", comment: ""), self.userInfo!.UserId as CVarArg) : nil;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.moreItems!.object(at: indexPath.row) as! NSArray
        let feature = item[1] as? EventFeatures
        let cellId = item[0] as! String
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MoreCell
        cell.Feature = feature
        cell.backgroundColor = .clear

        let cellIconId = NSLocalizedString("icon-\(cellId)", comment: "");

        // FontAwesome Icon
        let fontName = FontAwesome(rawValue: String(cellIconId.split(separator: " ").last!))
        var fontStyle : FontAwesomeStyle {
            switch String(cellIconId.split(separator: " ").first!) {
            case "fas":
                return FontAwesomeStyle.solid
            case "fab":
                return FontAwesomeStyle.brands
            default:
                return FontAwesomeStyle.solid
            }
        }

        cell.imageView!.image = UIImage.fontAwesomeIcon(name: fontName!, style: fontStyle, textColor: UIColor.black, size: CGSize(width: 24, height: 24))

        // Custome Icon
        let customIconUrl = feature?.Icon
        if (customIconUrl != nil) {
            let imageRequest = ImageRequest(url: customIconUrl!, targetSize: CGSize(width: 24*2, height: 24*2), contentMode: .aspectFill) //Nuke 7 is suck...

            Nuke.loadImage(
                with: imageRequest,
                options: ImageLoadingOptions(
                    placeholder: cell.imageView?.image,
                    transition: .fadeIn(duration: 0.33)
                ),
                into: cell.imageView!
            )
        }

        let cellText = cellId != ACKNOWLEDGEMENTS ?
            (feature?.DisplayText[Constants.shortLangUI] ?? "") :
            NSLocalizedString(cellId, comment: "")
        if ((OPassAPI.userInfo?.Role ?? "").count > 0 && !(feature?.VisibleRoles?.contains(OPassAPI.userInfo?.Role ?? "") ?? true)) {
            cell.isUserInteractionEnabled = false
        }

        cell.textLabel!.text = cellText
        return cell;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MoreCell
        let url = cell.Feature?.Url
        if (url != nil && cell.Feature?.Feature == OPassKnownFeatures.WebView.rawValue) {
            Constants.OpenInAppSafari(forURL: url!)
        }
        tableView.deselectRow(at: indexPath, animated: true)
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

    //#pragma mark - Table view delegate
    //- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    [tableView deselectRowAtIndexPath:indexPath
    //                             animated:YES];
    //    NSDictionary *item = [self.moreItems objectAtIndex:indexPath.row];
    //    NSString *title = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
    //    ((void(^)(NSString *))[item objectForKey:@"detailViewController"])(title);
    //    SEND_FIB_EVENT(@"MoreTableView", title);
    //}

    /*
     #pragma mark - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
         // Get the new view controller using [segue destinationViewController].
         // Pass the selected object to the new view controller.
     }
     */
}
