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
import Then
import MBProgressHUD

class AcknowledgementsViewController: UIViewController {
    var githubRepoLink: String?
    var progress: MBProgressHUD = MBProgressHUD.init()

    func configuration() {
        Promise { resolve, reject in
            var contributors = [Any]();
            let manager = AFHTTPSessionManager.init()
            manager.get("https://api.github.com/repos/CCIP-App/CCIP-iOS/contributors", parameters: nil, progress: nil, success: { (_, responseObject: Any?) in
                NSLog("JSON: \(JSONSerialization.stringify(responseObject as Any) ?? "nil")");
                if (responseObject != nil) {
                    if let contributorsObj = responseObject as? [NSDictionary] {
                        contributors = contributorsObj.map({ (dict: NSDictionary) -> CPDContribution in
                            let login = dict.object(forKey: "login") as? String ?? ""
                            let contributions = dict.object(forKey: "contributions") as? NSNumber ?? 0
                            let contributor: CPDContribution = CPDContribution.init(name: login, websiteAddress: Constants.GitHubRepo(login), role: "\(contributions) commits")
                            if let avatarUrl = dict.object(forKey: "avatar_url") as? String {
                                contributor.avatarAddress = avatarUrl
                            }
                            return contributor
                        })
                        resolve(contributors)
                    }
                }
            }) { (_, error: Error) in
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

            if let customAckJSONPath = bundle.path(forResource: "Project_3rd_Lib_License", ofType: "json") {
                do {
                    let customAckJSON = try String.init(contentsOfFile: customAckJSONPath, encoding: .utf8)
                    if let data = customAckJSON.data(using: .utf8) {
                        if let customAckArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [NSDictionary] {
                            for acknowledgementDict in customAckArray {
                                if let acknowledgement = acknowledgementDict as? [AnyHashable: Any] {
                                    acknowledgements?.append(CPDLibrary.init(cocoaPodsMetadataPlistDictionary: acknowledgement))
                                }
                            }
                        }
                    }
                } catch {
                    return obj
                }
            }

            guard let contributors = obj as? [CPDContribution] else { return obj }
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
        guard let website = contributor.object(forKey: "website") as? String else { return nil }
        guard let github = contributor.object(forKey: "github") as? NSDictionary else { return nil }
        guard let githubLogin = github.object(forKey: "login") as? String else { return nil }

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
        let avatarLink = contributor.object(forKey: "avatar_link") as? String ?? ""
        let gravatarHash = contributor.object(forKey: "gravatar_hash") as? String ?? ""
        let gravatarEmail = contributor.object(forKey: "gravatar_email") as? String ?? ""
        let github = contributor.object(forKey: "github") as? NSDictionary ?? [:]
        let githubId = github.object(forKey: "id") as? String ?? ""
        let githubLogin = github.object(forKey: "login") as? String ?? ""

        if (avatarLink.count > 0) {
            return avatarLink;
        } else if (gravatarHash.count > 0) {
            return Constants.GravatarAvatar(gravatarHash)
        } else if (gravatarEmail.count > 0) {
            if let emailData = gravatarEmail.data(using: .utf8) {
                let hashData = emailData as NSData
                if let md5 = hashData.md5Sum() {
                    let md5Hash = md5 as NSData
                    let hashString = md5Hash.hexString.lowercased()
                    return Constants.GravatarAvatar(hashString)
                }
            }
        } else if (githubId.count > 0) {
            return Constants.GitHubAvatar("u/\(githubId)")
        } else if (githubLogin.count > 0) {
            return Constants.GitHubAvatar(githubLogin)
        } else {
            return Constants.GravatarAvatar("")
        }
        return Constants.GravatarAvatar("")
    }

    @IBAction func openGithubRepo() {
        if let link = self.githubRepoLink {
            Constants.OpenInAppSafari(forPath: link)
        }
    }

    override func viewDidLoad() {
        self.configuration()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let title = self.navigationItem.title else { return }
        guard let titles = title.split(separator: "\t").last else { return }
        self.navigationItem.title = titles.trim()
        self.progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.progress.mode = .indeterminate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
