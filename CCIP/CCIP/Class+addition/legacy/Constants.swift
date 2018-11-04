//
//  Constants.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/5.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation

@objc extension Constants {
    public static var AccessToken : String {
        get {
            return Constants.accessToken();
        }
    }
    public static var AccessTokenSHA1 : String {
        get {
            return Constants.accessTokenSHA1();
        }
    }
    public static var URL_LOG_BOT : String {
        get {
            return Constants.urlLogBot();
        }
    };
    public static var URL_MAP : String {
        get {
            return Constants.appConfigURL("MapsPath");
        }
    }
    public static var URL_TELEGRAM_GROUP : String {
        get {
            return Constants.urlTelegramGroup();
        }
    }
    public static var URL_STAFF_WEB : String {
        get {
            return Constants.appConfigURL("StaffPath")
        }
    }
    public static var URL_SPONSOR_WEB : String {
        get {
            return Constants.appConfigURL("SponsorPath")
        }
    }
    public static var URL_GAME : String {
        get {
            return Constants.appConfigURL("GamePath")
        }
    }
}
