//
//  Localization.swift
//  OPass
//
//  Created by 張智堯 on 2022/5/3.
//  2022 OPass.
//

import Foundation

func LocalizeIn(zh: String, en: String) -> String{
    if Bundle.main.preferredLocalizations[0] ==  "zh-Hant" { return zh }
    else { return en }
}

func LocalizeIn(zh: String?, en: String?) -> String? {
    if Bundle.main.preferredLocalizations[0] ==  "zh-Hant" { return zh }
    else { return en }
}
