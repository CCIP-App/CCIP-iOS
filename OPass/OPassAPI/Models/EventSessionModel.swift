//
//  EventSessionsModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//

import Foundation

struct EventSessionModel: Hashable, Codable {
    var sessions = [SessionModel()]
    var speakers = [SpeakerModel()]
    var session_types = [Id_Name_DescriptionModel()]
    var rooms = [Id_Name_DescriptionModel()]
    var tags = [Id_Name_DescriptionModel()]
}

struct SessionModel: Hashable, Codable {
    var id: String = ""
    var type: String? = nil
    var room: String = ""
    var broadcast: [String]? = nil
    var start: String = ""
    var end: String = ""
    var qa: String? = nil
    var slide: String? = nil
    var live: String? = nil
    var record: String? = nil
    var pad: String? = nil
    var language: String? = nil
    var zh = Title_DescriptionModel()
    var en = Title_DescriptionModel()
    var speakers: [String] = [""]
    var tags: [String] = [""]
}

struct SpeakerModel: Hashable, Codable {
    var id: String = ""
    var avatar: String = ""
    var zh = Name_BioModel()
    var en = Name_BioModel()
}

struct Id_Name_DescriptionModel: Hashable, Codable {
    var id: String = ""
    var zh = Name_DescriptionModel()
    var en = Name_DescriptionModel()
}

struct Title_DescriptionModel: Hashable, Codable {
    var title: String = ""
    var description: String = ""
}

struct Name_BioModel: Hashable, Codable {
    var name: String = ""
    var bio: String = ""
}

struct Name_DescriptionModel: Hashable, Codable {
    var name: String = ""
    var description: String? = nil
}
