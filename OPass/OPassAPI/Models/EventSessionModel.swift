//
//  EventSessionsModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//

import Foundation
import SwiftDate

struct EventSessionModel: Hashable {
    var sessions = [[SessionModel()]]
    var speakers = [SpeakerModel()]
    var session_types = [Id_Name_DescriptionModel()]
    var rooms = [Id_Name_DescriptionModel()]
    var tags = [Id_Name_DescriptionModel()]
}

extension EventSessionModel: Decodable {
    enum CodingKeys: CodingKey {
        case sessions, speakers, session_types, rooms, tags
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        speakers = try container.decode([SpeakerModel].self, forKey: .speakers)
        session_types = try container.decode([Id_Name_DescriptionModel].self, forKey: .session_types)
        rooms = try container.decode([Id_Name_DescriptionModel].self, forKey: .rooms)
        tags = try container.decode([Id_Name_DescriptionModel].self, forKey: .tags)
        
        let sessions = try container.decode([SessionModel].self, forKey: .sessions)
        //transform sessions from [SessionModel] to a structed [[SessionModel]]
        self.sessions = sessions
            .sorted { $0.start < $1.start || $0.end <= $1.end }
            .reduce(into: [], { (sessionsAcrossDays: inout [[SessionModel]], currentSession) in
                if !sessionsAcrossDays.isEmpty && sessionsAcrossDays.last![0].onSameDay(as: currentSession) {
                    sessionsAcrossDays[sessionsAcrossDays.count-1].append(currentSession)
                } else {
                    sessionsAcrossDays.append([currentSession])
                }
            })
    }
}

extension SessionModel {
    func onSameDay(as session: SessionModel) -> Bool {
        //Note: we only compare its start time
        return self.start.sameDay(as: session.start)
    }
}

extension DateInRegion {
    func sameDay(as date: DateInRegion) -> Bool {
        return self.year == date.year &&
                self.month == date.month &&
                self.day == date.day
    }
}

struct SessionModel: Hashable {
    var id: String = ""
    var type: String? = nil
    var room: String = ""
    var broadcast: [String]? = nil
    var start: DateInRegion = DateInRegion() //use DateInRegion from SwiftDate to keep timezone data
    var end: DateInRegion = DateInRegion()
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

//Since we use DateInRegion as the type of start and end, we have to again customize the json decode
extension SessionModel: Decodable {
    enum CodingKeys: CodingKey {
        case id, type, room, broadcast, start, end, qa, slide, live, record, pad, language, zh, en, speakers, tags
    }
    //how can we avoid these boilerplate?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.room = try container.decode(String.self, forKey: .room)
        self.broadcast = try container.decodeIfPresent([String].self, forKey: .broadcast)
        self.qa = try container.decodeIfPresent(String.self, forKey: .qa)
        self.slide = try container.decodeIfPresent(String.self, forKey: .slide)
        self.live = try container.decodeIfPresent(String.self, forKey: .live)
        self.record = try container.decodeIfPresent(String.self, forKey: .record)
        self.pad = try container.decodeIfPresent(String.self, forKey: .pad)
        self.language = try container.decodeIfPresent(String.self, forKey: .language)
        self.zh = try container.decode(Title_DescriptionModel.self, forKey: .zh)
        self.en = try container.decode(Title_DescriptionModel.self, forKey: .en)
        self.speakers = try container.decode([String].self, forKey: .speakers)
        self.tags = try container.decode([String].self, forKey: .tags)
        
        let startString = try container.decode(String.self, forKey: .start)
        let endString = try container.decode(String.self, forKey: .end)
        
        self.start = startString.toISODate()!
        self.end = endString.toISODate()!
        print(self.start)
    }
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
