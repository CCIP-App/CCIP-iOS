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
    var id = ""
    var type: String?
    var room = ""
    var broadcast: [String]?
    var start = ""
    var end = ""
    var qa: String?
    var slide: String?
    var live: String?
    var record: String?
    var pad: String?
    var language: String?
    var zh = Title_DescriptionModel()
    var en = Title_DescriptionModel()
    var speakers = [""]
    var tags = [""]
}

struct SpeakerModel: Hashable, Codable {
    var id = ""
    var avatar = ""
    var zh = Name_BioModel()
    var en = Name_BioModel()
}

struct Id_Name_DescriptionModel: Hashable, Codable {
    var id = ""
    var zh = Name_DescriptionModel()
    var en = Name_DescriptionModel()
}

struct Title_DescriptionModel: Hashable, Codable {
    var title = ""
    var description = ""
}

struct Name_BioModel: Hashable, Codable {
    var name = ""
    var bio = ""
}

struct Name_DescriptionModel: Hashable, Codable {
    var name = ""
    var description: String?
}
