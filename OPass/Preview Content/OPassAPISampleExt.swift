//
//  OPassAPISampleExt.swift
//  OPass
//
//  Created by secminhr on 2022/3/2.
//

import Foundation

fileprivate func loadJson<T: Decodable>(filename: String) -> T {
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

extension OPassAPIModels {
    static func mock() -> OPassAPIModels {
        let model = OPassAPIModels()
        model.eventLogo = Data()
        model.eventList = loadJson(filename: "eventListSample.json")
        model.eventSettings = loadJson(filename: "eventSettingsSample.json")
        return model
    }
}
