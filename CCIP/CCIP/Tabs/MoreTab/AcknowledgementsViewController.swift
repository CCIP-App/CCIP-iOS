//
//  AcknowledgementsViewController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/2/8.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import UIKit
import CPDAcknowledgements
import SafariServices
import AFNetworking
import then
import MBProgressHUD

class AcknowledgementsViewController : UIViewController {
    var githubRepoLink: String?
    var progress: MBProgressHUD = MBProgressHUD.init()

    func configuration() {
        Promise { resolve, reject in
            var contributors = [Any]();

            //        let filePath = Bundle.main.path(forResource: "Project_Info_and_Contributors", ofType: "json")
            //        let projectInfoJSON = try! String.init(contentsOfFile: filePath!, encoding: .utf8)
            //        let projectInfoData = (try! JSONSerialization.jsonObject(with: projectInfoJSON.data(using: .utf8)!, options: .mutableContainers)) as! [String: NSObject]
            //        let selfContributorIndexList = (projectInfoData["self"]! as! [String: NSObject])["contributors"] as! [NSNumber]
            //        let allContributorArray = projectInfoData["contributors"] as! [NSDictionary];
            //
            //        for contributorIndex in selfContributorIndexList {
            //            for contributorDict in allContributorArray {
            //                if contributorDict.object(forKey: "index") as! NSNumber == contributorIndex {
            //                    let contributor: CPDContribution = CPDContribution.init(name: contributorDict.object(forKey: "nick_name") as! String, websiteAddress: self.getWebsiteAddress(contributor: contributorDict ), role: contributorDict.object(forKey: "role") as! String)
            //                    contributor.avatarAddress = self.getAvatarAddress(contributor: contributorDict )
            //                    contributors.append(contributor)
            //                    break
            //                }
            //            }
            //        }

            let manager = AFHTTPSessionManager.init()
            manager.get("https://api.github.com/repos/CCIP-App/CCIP-iOS/contributors", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
                NSLog("JSON: \(JSONSerialization.stringify(responseObject as Any)!)");
                if (responseObject != nil) {
                    let contributorsObj = responseObject as! [NSDictionary]
                    contributors = contributorsObj.map({ (dict: NSDictionary) -> CPDContribution in
                        let contributor: CPDContribution = CPDContribution.init(name: dict.object(forKey: "login") as! String, websiteAddress: Constants.GitHubRepo(dict.object(forKey: "login") as! String), role: "\(dict.object(forKey: "contributions") as! NSNumber) commits")
                        contributor.avatarAddress = (dict.object(forKey: "avatar_url") as! String)
                        return contributor
                    })
                    resolve(contributors)
                }
            }) { (operation: URLSessionDataTask?, error: Error) in
                NSLog("Error: \(error)");
                reject(error)
            }
        }.then { (obj: Any) -> Any in
            //        let githubRepo = (projectInfoData["self"]! as! [String: NSObject])["github_repo"] as! String?
            //        if githubRepo != nil && githubRepo != "" {
            //            self.githubRepoLink = Constants.GitHubRepo(githubRepo!)
            //        }

            self.githubRepoLink = Constants.GitHubRepo("CCIP-App/CCIP-iOS")
            if (self.githubRepoLink != nil) {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: Constants.AssertImage("AssetsUI", "ToolButton-GitHub_Filled"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(AcknowledgementsViewController.openGithubRepo))
            }

            let bundle = Bundle.main
            var acknowledgements = CPDCocoaPodsLibrariesLoader.loadAcknowledgements(with: bundle)

            let customAckJSONPath = bundle.path(forResource: "Project_3rd_Lib_License", ofType: "json")
            let customAckJSON = try! String.init(contentsOfFile: customAckJSONPath!, encoding: .utf8)
            let customAckArray = try! JSONSerialization.jsonObject(with: customAckJSON.data(using: .utf8)!, options: .allowFragments) as! [NSDictionary]

            for acknowledgementDict in customAckArray {
                acknowledgements?.append(CPDLibrary.init(cocoaPodsMetadataPlistDictionary: acknowledgementDict as! [AnyHashable : Any]))
            }

            let contributors = obj as! [CPDContribution]
            let acknowledgementsViewController: CPDAcknowledgementsViewController = CPDAcknowledgementsViewController.init(style: nil, acknowledgements: acknowledgements, contributions: contributors)
            self.addChild(acknowledgementsViewController)
            var frame = self.view.frame
            frame.origin.y = 0 // force to align the top when data lag to delivered
            acknowledgementsViewController.view.frame = frame;
            self.view.addSubview(acknowledgementsViewController.view)
            acknowledgementsViewController.didMove(toParent: self)
            return acknowledgementsViewController
        }.then { (vc: Any) -> Any in
            self.progress.hide(animated: true)
            return vc
        }
    }

    func getWebsiteAddress(contributor: NSDictionary) -> String? {
        // website > github_site(github.login) > nil
        let website = contributor.object(forKey: "website") as! String
        let githubLogin = (contributor.object(forKey: "github") as! NSDictionary).object(forKey: "login") as! String

        if (website.count > 0) {
            return website;
        } else {
            if (githubLogin.count > 0) {
                return Constants.GitHubRepo(githubLogin);
            } else {
                return nil;
            }
        }
    }

    func getAvatarAddress(contributor: NSDictionary) -> String? {
        // avatar_link > gravatar_email > github_avatar (github.id > github.login) > default
        let avatarLink = contributor.object(forKey: "avatar_link") as! String
        let gravatarHash = contributor.object(forKey: "gravatar_hash") as! String
        let gravatarEmail = contributor.object(forKey: "gravatar_email") as! String
        let github = contributor.object(forKey: "github") as! NSDictionary
        let githubId = github.object(forKey: "id") as! String
        let githubLogin = github.object(forKey: "login") as! String

        if (avatarLink.count > 0) {
            return avatarLink;
        } else if (gravatarHash.count > 0) {
            return Constants.GravatarAvatar(gravatarHash);
        } else if (gravatarEmail.count > 0) {
            let hashData = gravatarEmail.data(using: .utf8)! as NSData
            let md5Hash = hashData.md5Sum()! as NSData
            let hashString = md5Hash.hexString.lowercased()
            return Constants.GravatarAvatar(hashString)
        } else if (githubId.count > 0) {
            return Constants.GitHubAvatar("u/\(githubId)");
        } else if (githubLogin.count > 0) {
            return Constants.GitHubAvatar(githubLogin);
        } else {
            return Constants.GravatarAvatar("");
        }
    }

    @IBAction func openGithubRepo() {
        let url = URL.init(string: self.githubRepoLink!)
        if (SFSafariViewController.className != "") {
            // Open in SFSafariViewController
            let safariViewController = SFSafariViewController.init(url: url!)
            self.present(safariViewController, animated: true, completion: nil)
        } else {
            // Open in Mobile Safari
            UIApplication.shared.open(url!, options: [:]) { (success: Bool) in
                if success {
                    NSLog("Failed to open url: \(String(describing: url))")
                }
            }
        }
    }

    override func viewDidLoad() {
        self.configuration()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.progress.mode = .indeterminate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
