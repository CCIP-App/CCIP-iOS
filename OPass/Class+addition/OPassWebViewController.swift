//
//  UIViewController+WebView.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/5.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SafariServices
import NJKWebViewProgress

protocol OPassWebViewIB {
    var goReloadButton: UIBarButtonItem? { get }
    var goBackButton: UIBarButtonItem? { get }
    var goForwardButton: UIBarButtonItem? { get }
    
    func reload(_ sender: Any);
    func goBack(_ sender: Any);
    func goForward(_ sender: Any);
    
    var titleTextColor: String { get }
    var titleLeftColor: String { get }
    var titleRightColor: String { get }
    
    var PageUrl : String { get }
    
    var ShowLogo : Bool { get }
}

extension OPassWebViewIB { // for all of optional properties and func used in OPassWebViewIB protoccol
    var goReloadButton: UIBarButtonItem? { return nil }
    var goBackButton: UIBarButtonItem? { return nil }
    var goForwardButton: UIBarButtonItem? { return nil }

    func reload(_ sender: Any) {}
    func goBack(_ sender: Any) {}
    func goForward(_ sender: Any) {}

    var titleTextColor: String { return "" }
    var titleLeftColor: String { return "" }
    var titleRightColor: String { return "" }

    var PageUrl : String { return "" }

    var ShowLogo : Bool { return false }
}

class OPassWebViewController : UIViewController, WKNavigationDelegate, WKUIDelegate {
    /* fake dummy obj */ private var goReloadButton: UIBarButtonItem? = nil;
    /* fake dummy obj */ private var goBackButton: UIBarButtonItem? = nil;
    /* fake dummy obj */ private var goForwardButton: UIBarButtonItem? = nil;
    
    /* fake dummy obj */ private var titleTextColor: String = "";
    /* fake dummy obj */ private var titleLeftColor: String = "";
    /* fake dummy obj */ private var titleRightColor: String = "";
    
    /* fake dummy obj */ private var PageUrl: String = "";
    
    /* fake dummy obj */ private var ShowLogo: Bool = false;
    
    private var shimmeringLogoView: FBShimmeringView?;
    private var webView: WKWebView?;
    private var progressView: NJKWebViewProgressView?;
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    func parseInstanceObjects() {
        self.goReloadButton = self.valueForKeyPaths("goReloadButton") as? UIBarButtonItem;
        self.goBackButton = self.valueForKeyPaths("goBackButton") as? UIBarButtonItem;
        self.goForwardButton = self.valueForKeyPaths("goForwardButton") as? UIBarButtonItem;
        self.titleTextColor = self.valueForKeyPaths("titleTextColor") as? String ?? "";
        self.titleLeftColor = self.valueForKeyPaths("titleLeftColor") as? String ?? "";
        self.titleRightColor = self.valueForKeyPaths("titleRightColor") as? String ?? "";
        self.PageUrl = self.valueForKeyPaths("PageUrl") as? String ?? "";
        self.ShowLogo = self.valueForKeyPaths("ShowLogo") as? Bool ?? false;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.parseInstanceObjects();

        self.navigationItem.title = self.navigationItem.title?.split(separator: "\t").last!.trim()

        if (self.ShowLogo) {
            // set logo on nav title
            let logoView = UIImageView.init(image: Constants.ConfLogo());
            self.shimmeringLogoView = FBShimmeringView.init(frame: logoView.bounds);
            self.shimmeringLogoView?.contentView = logoView;
            self.navigationItem.titleView = self.shimmeringLogoView;
        } else {
            self.navigationItem.titleView?.tintColor = AppDelegate.appConfigColor(self.titleTextColor);
        }
        
        Constants.sendFIB(self.className);
        
        let progressBarHeight : CGFloat = 2;
        let navigationBarBounds = self.navigationController!.navigationBar.bounds;
        let barFrame = CGRect(x: 0, y: navigationBarBounds.size.height - progressBarHeight, width: navigationBarBounds.size.width, height: progressBarHeight);
        self.progressView = NJKWebViewProgressView.init(frame: barFrame);
        self.progressView?.progressBarView.backgroundColor = AppDelegate.appConfigColor("ProgressBarColor");
        self.progressView?.autoresizingMask = [ .flexibleWidth, .flexibleTopMargin ];
        self.navigationController?.navigationBar.addSubview(self.progressView!);
        
        if (self.ShowLogo && self.titleLeftColor != "" && self.titleRightColor != "") {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default);
            self.navigationController?.navigationBar.shadowImage = UIImage();
            self.navigationController?.navigationBar.backgroundColor = UIColor.clear;
            let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.navigationController!.navigationBar.frame.origin.y + navigationBarBounds.size.height);
            let headView = UIView();
            headView.frame = frame;
            headView.setGradientColor(
                from: AppDelegate.appConfigColor(self.titleLeftColor),
                to: AppDelegate.appConfigColor(self.titleRightColor),
                startPoint: CGPoint(x: -0.4, y: 0.5),
                toPoint: CGPoint(x: 1, y: 0.5)
            );
            self.view.addSubview(headView);
            self.view.sendSubviewToBack(headView);
        }
        
        self.webView = WKWebView();
        self.webView?.translatesAutoresizingMaskIntoConstraints = false;
        self.webView?.navigationDelegate = self;
        self.webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil);
        self.view.insertSubview(self.webView!, at: 0);
        
        self.checkButtonStatus(false);
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.parseInstanceObjects(); // reload again for url
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        self.setWebViewConstraints();
        AppDelegate.setDevLogo(self.shimmeringLogoView, withLogo: Constants.ConfLogo());
        
        self.reload(self);
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.webView?.stopLoading()
        self.progressView?.setProgress(1, animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.progressView?.removeFromSuperview()
    }

    func setWebViewConstraints() {
        let layoutGuide = UILayoutGuide();
        self.webView?.addLayoutGuide(layoutGuide);
        self.webView!.safeAreaLayoutGuide.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true;
        self.webView!.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true;
        self.webView!.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true;
        self.webView!.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true;
    }
    
    func reload(_ sender: Any) {
        var nsurl = self.webView?.url;
        if ((nsurl?.absoluteString ?? "") == "") {
            nsurl = URL(string: self.PageUrl);
            let requestObj = URLRequest(url: nsurl!);
            self.webView?.load(requestObj);
        } else {
            self.webView?.reload();
        }
        self.checkButtonStatus();
    }
    
    func goBack(_ sender: Any) {
        self.webView?.goBack();
    }
    
    func goForward(_ sender: Any) {
        self.webView?.goForward();
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.checkButtonStatus();
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.checkButtonStatus();
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.checkButtonStatus();
    }
    
    func checkButtonStatus(_ forceEnabled : Bool? = nil) {
        if (self.goReloadButton != nil) {
            self.goReloadButton!.isEnabled = forceEnabled ?? !(self.webView?.isLoading)!;
        }
        if (self.goBackButton != nil) {
            self.goBackButton!.isEnabled = forceEnabled ?? (self.webView?.canGoBack)!;
        }
        if (self.goForwardButton != nil) {
            self.goForwardButton!.isEnabled = forceEnabled ?? (self.webView?.canGoForward)!;
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.navigationType == .linkActivated) {
            let url = navigationAction.request.url;
            
            if (url!.host == URL(string: self.PageUrl)!.host) {
                decisionHandler(.allow);
                return;
            } else {
                Constants.OpenInAppSafari(forURL: url!)
                decisionHandler(.cancel);
                return;
            }
        }
        decisionHandler(.allow);
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress" && object as! WKWebView? == self.webView) {
            print("WebPage Loading Progress: \(self.webView?.estimatedProgress ?? 0)");
            // estimatedProgress is a value from 0.0 to 1.0
            // Update your UI here accordingly
            self.progressView?.setProgress(Float((self.webView?.estimatedProgress)!), animated: true);
        } else {
            // Make sure to call the superclass's implementation in the else block in case it is also implementing KVO
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context);
        }
    }
}
