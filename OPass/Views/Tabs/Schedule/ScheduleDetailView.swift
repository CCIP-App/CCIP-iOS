//
//  ScheduleDetailView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/27.
//

import SwiftUI
import SwiftDate

struct ScheduleDetailView: View {
    
    @State var scheduleDetail: SessionModel
    let speakers: [String: SpeakerModel]
    let rooms: [String : Name_DescriptionPair]
    let tags: [String : Name_DescriptionPair]
    
    init(
        scheduleDetail: SessionModel,
        speakersData: [String: SpeakerModel],
        roomsData: [String: Name_DescriptionPair],
        tagsData: [String: Name_DescriptionPair]
    ) {
        self._scheduleDetail = State(initialValue: scheduleDetail)
        self.speakers = speakersData
        self.rooms = roomsData
        self.tags = tagsData
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").edgesIgnoringSafeArea(.bottom)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    TagsSection(tagsID: scheduleDetail.tags, tags: tags)
                        .padding(.vertical, 8)
                    
                    Text(scheduleDetail.zh.title)
                        .font(.largeTitle.bold())
                    
                    FeatureButtons(scheduleDetail: scheduleDetail)
                        .padding(.vertical)
                    
                    PlaceSection(name: rooms[scheduleDetail.room]?.zh.name ?? scheduleDetail.room)
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(.bottom)
                    
                    TimeSection(scheduleDetail: scheduleDetail)
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Speakers").font(.caption)
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                        
                        ForEach(scheduleDetail.speakers, id: \.self) { speaker in
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .center) {
                                    //TODO: Avatar feature
                                    //if let speakerData = speakers[speaker],
                                    //   let avatarData = speakerData.avatarData,
                                    //   let avatarUIImage = UIImage(data: avatarData) {
                                    //    Image(uiImage: avatarUIImage)
                                    //        .clipShape(Circle())
                                    //        .font(.title)
                                    //}
                                    Text(speakers[speaker]?.zh.name ?? speaker)
                                        .font(.subheadline.bold())
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                if let speakerData = speakers[speaker], speakerData.zh.bio != "" {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Divider()
                                        Text(speakerData.zh.bio)
                                            .padding(.vertical, 8)
                                            .font(.caption)
                                            .lineLimit(2)
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                            .background(Color.white)
                            .cornerRadius(8)
                            .padding(.top, 8)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    SFButton(systemName: "square.and.arrow.up") {
                        
                    }
                    
                    SFButton(systemName: "heart") {
                        
                    }
                }
            }
        }
    }
}

fileprivate struct TagsSection: View {
    
    let tagsID: [String]
    let tags: [String : Name_DescriptionPair]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(tagsID, id: \.self) { tagID in
                    Text(tags[tagID]?.zh.name ?? tagID)
                        .font(.caption)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .foregroundColor(Color.black)
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(5)
                }
            }
        }
    }
}

fileprivate struct PlaceSection: View {
    
    let name: String
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "map").foregroundColor(Color.blue)
                .padding()
            VStack(alignment: .leading) {
                Text("Place").font(.caption)
                    .foregroundColor(.gray)
                Text(name)
            }
            Spacer()
        }
    }
}

fileprivate struct TimeSection: View {
    
    let start: DateInRegion
    let end: DateInRegion
    let durationMinute: Int
    
    init(scheduleDetail: SessionModel) {
        self.start = scheduleDetail.start
        self.end = scheduleDetail.end
        self.durationMinute = Int((scheduleDetail.end - scheduleDetail.start) / 60)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "clock").foregroundColor(Color.red)
                .padding()
            VStack(alignment: .leading) {
                Text(String(format: "%d/%d/%d", start.year, start.month, start.day))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(String(format: "%d:%02d ~ %d:%02d • %d minutes", start.hour, start.minute, end.hour, end.minute, durationMinute))
            }
            Spacer()
        }
    }
}

fileprivate struct FeatureButtons: View {
    
    @Environment(\.openURL) var openURL
    let scheduleDetail: SessionModel
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                if let liveURL = scheduleDetail.live {
                    VStack {
                        Button(action: {
                            openURL(URL(string: liveURL)!)
                        }) {
                            Image(systemName: "video")
                                .font(.largeTitle)
                                .padding(CGFloat(8))
                        }
                        .aspectRatio(contentMode: .fill)
                        .padding()
                        .tint(Color.black)
                        .background(Color.white)
                        .cornerRadius(10)
                        Text("Live")
                            .font(.caption2)
                    }
                }
                if let padURL = scheduleDetail.pad {
                    VStack {
                        Button(action: {
                            openURL(URL(string: padURL)!)
                        }) {
                            Image(systemName: "keyboard")
                                .font(.largeTitle)
                                .padding(CGFloat(8))
                        }
                        .aspectRatio(contentMode: .fill)
                        .padding()
                        .tint(Color.black)
                        .background(Color.white)
                        .cornerRadius(10)
                        Text("Co-writing")
                            .font(.caption2)
                    }
                }
                if let recordURL = scheduleDetail.record {
                    VStack {
                        Button(action: {
                            openURL(URL(string: recordURL)!)
                        }) {
                            Image(systemName: "play")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .font(.title)
                                .padding(CGFloat(8))
                        }
                        .aspectRatio(contentMode: .fill)
                        .padding()
                        .tint(Color.black)
                        .background(Color.white)
                        .cornerRadius(10)
                        Text("Record")
                            .font(.caption2)
                    }
                }
                if let slideURL = scheduleDetail.slide {
                    VStack {
                        Button(action: {
                            openURL(URL(string: slideURL)!)
                        }) {
                            Image(systemName: "paperclip")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(CGFloat(8))
                        }
                        .aspectRatio(contentMode: .fill)
                        .padding()
                        .tint(Color.black)
                        .background(Color.white)
                        .cornerRadius(10)
                        Text("Slide")
                            .font(.caption2)
                    }
                }
                if let qaURL = scheduleDetail.qa {
                    VStack {
                        Button(action: {
                            openURL(URL(string: qaURL)!)
                        }) {
                            Image(systemName: "questionmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(CGFloat(8))
                        }
                        .aspectRatio(contentMode: .fill)
                        .padding()
                        .tint(Color.black)
                        .background(Color.white)
                        .cornerRadius(10)
                        Text("QA")
                            .font(.caption2)
                    }
                }
            }
        }
    }
}

fileprivate extension Array {
    func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}

//#if DEBUG
//struct ScheduleDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScheduleDetailView()
//    }
//}
//#endif
