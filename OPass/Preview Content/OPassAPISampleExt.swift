//
//  OPassAPISampleExt.swift
//  OPass
//
//  Created by secminhr on 2022/3/2.
//  2022 OPass.
//

import Foundation

func loadJson<T: Decodable>(filename: String) -> T {
    guard let fileURL = Bundle.main.url(forResource: filename, withExtension: nil) else {
        fatalError("Couldn't find \(filename).")
    }
    
    do {
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.userInfo[.needTransform] = true
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't load \(fileURL.path) and parse it as \(T.self). \nError: \(error)")
    }
}

extension OPassAPIService {
    static func mock() -> OPassAPIService {
        let model = OPassAPIService()
        let list: [EventTitleModel] = loadJson(filename: "eventListSample.json")
        let settings: SettingsModel = loadJson(filename: "eventSettingsSample.json")
        model.currentEventID = list[0].event_id
        model.currentEventAPI = EventAPIViewModel(settings)
        return model
    }
}

extension SettingsModel {
    static func mock() -> SettingsModel {
        return loadJson(filename: "eventSettingsSample.json")
    }
}
