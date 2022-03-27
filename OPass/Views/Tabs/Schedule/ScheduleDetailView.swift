//
//  ScheduleDetailView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/27.
//

import SwiftUI

struct ScheduleDetailView: View {
    
    let scheduleDetail: SessionModel
    let speakers: [String: SpeakerModel]
    let rooms: [String : Id_Name_DescriptionModel]
    let tags: [String : Id_Name_DescriptionModel]
    
    init(
        scheduleDetail: SessionModel,
        speakersData: [SpeakerModel],
        roomsData: [Id_Name_DescriptionModel],
        tagsData: [Id_Name_DescriptionModel]
    ) {
        self.scheduleDetail = scheduleDetail
        self.speakers = speakersData.toDictionary {$0.id}
        self.rooms = roomsData.toDictionary {$0.id}
        self.tags = tagsData.toDictionary {$0.id}
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").edgesIgnoringSafeArea(.bottom)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        ForEach(scheduleDetail.tags, id: \.self) { tag in
                            Text(tags[tag]?.zh.name ?? tag)
                                .font(.caption)
                                .padding(5)
                                .foregroundColor(Color.black)
                                .background(Color.black.opacity(0.1))
                                .cornerRadius(5)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    Text(scheduleDetail.zh.title)
                        .font(.largeTitle.bold())
                    
                    FeatureButtons(scheduleDetail: scheduleDetail)
                        .padding(.vertical)
                    
                    HStack {
                        Image(systemName: "")
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
