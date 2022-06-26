//
//  ProcessURL.swift
//  OPass
//
//  Created by 張智堯 on 2022/6/26.
//  2022 OPass.
//

import Foundation

func processURL(_ rawURL: URL) -> URL? {
    var result: URL? = rawURL
    if !rawURL.absoluteString.lowercased().hasPrefix("http") {
        result = URL(string: "http://" + rawURL.absoluteString)
    }
    return result
}
