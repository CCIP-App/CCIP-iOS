//
//  OPassAPISampleExt.swift
//  OPass
//
//  Created by secminhr on 2022/3/2.
//  2023 OPass.
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

extension OPassService {
    static func mock() -> OPassService {
        let model = OPassService()
        let list: [Event] = loadJson(filename: "eventListSample.json")
        let settings: EventConfig = loadJson(filename: "eventSettingsSample.json")
        model.currentEventID = list[0].id
        model.currentEventAPI = EventService(settings)
        return model
    }
}

extension EventConfig {
    static func mock() -> EventConfig {
        return loadJson(filename: "eventSettingsSample.json")
    }
}
