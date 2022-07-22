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
        return try JSONDecoder().decode(T.self, from: data)
    } catch {
        fatalError("Couldn't load \(fileURL.path) and parse it as \(T.self). \nError: \(error)")
    }
}

extension OPassAPIViewModel {
    static func mock() -> OPassAPIViewModel {
        let model = OPassAPIViewModel()
        model.eventList = loadJson(filename: "eventListSample.json")
        model.currentEventID = model.eventList[0].event_id
        let settings = SettingsModel.mock()
        model.currentEventAPI = EventAPIViewModel(settings)
        return model
    }
}

extension SettingsModel {
    static func mock() -> SettingsModel {
        return loadJson(filename: "eventSettingsSample.json")
    }
}
