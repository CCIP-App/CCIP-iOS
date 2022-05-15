//
//  ScheduleDetailView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/27.
//  2022 OPass.
//

import SwiftUI
import SwiftDate
import MarkdownUI
import SlideOverCard
import BetterSafariView

struct ScheduleDetailView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    let scheduleDetail: SessionDataModel
    @AppStorage var likedSessions: [String]
    @State var isShowingSpeakerDetail: Bool = false
    @State var showSpeaker: String?
    @State var url: URL = URL(string: "https://opass.app")!
    @State var showingUrlAlert = false
    @State var showingSafari = false
    private var isLiked: Bool {
        likedSessions.contains(scheduleDetail.id)
    }
    
    init(eventAPI: EventAPIViewModel, scheduleDetail: SessionDataModel) {
        _eventAPI = ObservedObject(wrappedValue: eventAPI)
        self.scheduleDetail = scheduleDetail
        _likedSessions = AppStorage(wrappedValue: [], "liked_sessions", store: UserDefaults(suiteName: eventAPI.event_id))
    }
    
    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 0) {
                TagsSection(tagsID: scheduleDetail.tags, tags: eventAPI.eventSchedule?.tags.data ?? [:])
                    .padding(.vertical, 8)
                
                Text(LocalizeIn(zh: scheduleDetail.zh.title, en: scheduleDetail.en.title))
                    .font(.largeTitle.bold())
                    .fixedSize(horizontal: false, vertical: true)
                
                FeatureButtons(scheduleDetail: scheduleDetail)
                    .padding(.vertical)
                    .environment(
                        \.openURL,
                         OpenURLAction { url in
                             self.url = url
                             self.showingSafari = true
                             return .handled
                         }
                    )
                
                if let type = scheduleDetail.type {
                    TypeSection(name: LocalizeIn(zh: eventAPI.eventSchedule?.session_types.data[type]?.zh.name,
                                                 en: eventAPI.eventSchedule?.session_types.data[type]?.en.name) ?? type)
                    .background(Color("SectionBackgroundColor"))
                    .cornerRadius(8)
                    .padding(.bottom)
                }
                
                PlaceSection(name: LocalizeIn(zh: eventAPI.eventSchedule?.rooms[scheduleDetail.room]?.zh.name,
                                              en: eventAPI.eventSchedule?.rooms[scheduleDetail.room]?.en.name) ?? scheduleDetail.room)
                    .background(Color("SectionBackgroundColor"))
                    .cornerRadius(8)
                    .padding(.bottom)
                
                TimeSection(scheduleDetail: scheduleDetail)
                    .background(Color("SectionBackgroundColor"))
                    .cornerRadius(8)
            }
            .listRowBackground(Color.transparent)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .alert(LocalizedStringKey("Open \(url)?"), isPresented: $showingUrlAlert) {
                Button(String(localized: "Cancel"), role: .cancel) {}
                Button(String(localized: "Yes")) { showingSafari.toggle() }
            }
            .safariView(isPresented: $showingSafari) {
                SafariView(
                    url: url,
                    configuration: SafariView.Configuration(
                        entersReaderIfAvailable: false,
                        barCollapsingEnabled: true
                    )
                )
                //.preferredBarAccentColor(.white)
                //.preferredControlAccentColor(.accentColor)
                .dismissButtonStyle(.cancel)
            }
                
            if scheduleDetail.speakers.count != 0 {
                SpeakersSection(eventAPI: eventAPI, scheduleDetail: scheduleDetail, showSpeaker: $showSpeaker, url: $url, showingAlert: $showingUrlAlert)
            }
            
            if let description = scheduleDetail.zh.description, description != "" {
                DescriptionSection(description: description, url: $url, showingAlert: $showingUrlAlert)
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    SFButton(systemName: "square.and.arrow.up") {
                        
                    }.hidden() //Disable temporary until OPass server udpate feature
                    
                    SFButton(systemName: "heart\(isLiked ? ".fill" : "")") {
                        UNUserNotification.registeringNotification(
                            id: scheduleDetail.id,
                            title: String(localized: "SessionWillStartIn5Minutes"),
                            content: String(format: String(localized: "SessionWillStartIn5MinutesContent"),
                                            scheduleDetail.en.title,
                                            eventAPI.eventSchedule?.rooms[scheduleDetail.room]?.en.name ?? ""),
                            rawTime: scheduleDetail.start,
                            cancel: isLiked
                        )
                        if isLiked {
                            SoundManager.instance.play(sound: .don)
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                            likedSessions.removeAll { $0 == scheduleDetail.id }
                        } else {
                            SoundManager.instance.play(sound: .din)
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            likedSessions.append(scheduleDetail.id)
                        }
                    }
                }
            }
        }
    }
}

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}

fileprivate struct TagsSection: View {
    
    @Environment(\.colorScheme) var colorScheme
    let tagsID: [String]
    let tags: [String : Name_DescriptionPair]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(tagsID, id: \.self) { tagID in
                    Text(LocalizeIn(zh: tags[tagID]?.zh.name, en: tags[tagID]?.en.name) ?? tagID)
                        .font(.caption)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .background((colorScheme == .dark ? Color.white : Color.black).opacity(0.1))
                        .cornerRadius(5)
                }
            }
        }
    }
}

//Feature button size need to be fixed not dynamic 
fileprivate struct FeatureButtons: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    let scheduleDetail: SessionDataModel
    let buttonSize = CGFloat(62)
    let features: [(String, String, String)]
    
    init(scheduleDetail: SessionDataModel) {
        self.scheduleDetail = scheduleDetail
        features = [
            (scheduleDetail.live, "video", "Live"),
            (scheduleDetail.pad, "keyboard", "CoWriting"),
            (scheduleDetail.record, "play", "Record"),
            (scheduleDetail.slide, "paperclip", "Slide"),
            (scheduleDetail.qa, "questionmark", "QA")
        ].filter { (url, _, _) in url != nil } as! [(String, String, String)]
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(features, id: \.0, content: { (url, systemImageName, text) in
                    VStack {
                        Button(action: {
                            openURL(URL(string: url)!)
                        }) {
                            Image(systemName: systemImageName)
                                .font(.system(size: 23, weight: .semibold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .gray : Color(red: 72/255, green: 72/255, blue: 74/255))
                                .frame(width: buttonSize, height: buttonSize)
                                .background(Color("SectionBackgroundColor"))
                                .cornerRadius(10)
                        }
                        Text(LocalizedStringKey(text))
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                   }
                })
            }
        }
    }
}

fileprivate struct TypeSection: View {
    
    let name: String
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "signpost.right")
                .foregroundColor(Color(red: 1, green: 204/255, blue: 0, opacity: 1))
                .padding()
            VStack(alignment: .leading) {
                Text(LocalizedStringKey("Type")).font(.caption)
                    .foregroundColor(.gray)
                Text(name)
            }
            Spacer()
        }
    }
}

fileprivate struct PlaceSection: View {
    
    let name: String
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "map")
                .foregroundColor(Color.blue)
                .padding()
            VStack(alignment: .leading) {
                Text(LocalizedStringKey("Place")).font(.caption)
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
    
    init(scheduleDetail: SessionDataModel) {
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
                
                Text(String(format: String(localized: "TimeWithLengthContent"), start.hour, start.minute, end.hour, end.minute, durationMinute))
            }
            Spacer()
        }
    }
}

fileprivate struct SpeakersSection: View {
    
    @State var forceFullText: Bool = false
    @ObservedObject var eventAPI: EventAPIViewModel
    let scheduleDetail: SessionDataModel
    @Binding var showSpeaker: String?
    @Binding var url: URL
    @Binding var showingAlert: Bool
    
    var body: some View {
        Section(header: Text(LocalizedStringKey("Speakers")).padding(.leading, 10)) {
            ForEach(scheduleDetail.speakers, id: \.self) { speaker in
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center) {
                        if let avatarURL = eventAPI.eventSchedule?.speakers[speaker]?.avatar {
                            AsyncImage(url: URL(string: avatarURL)) { image in
                                image
                                    .renderingMode(.original)
                                    .resizable().scaledToFill()
                                    .transition(.opacity)
                            } placeholder: {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable().scaledToFit()
                                    .foregroundColor(.gray)
                            }
                            .clipShape(Circle())
                            .frame(width: 30, height: 30)
                        }
                        
                        Text(LocalizeIn(zh: eventAPI.eventSchedule?.speakers[speaker]?.zh.name, en: eventAPI.eventSchedule?.speakers[speaker]?.en.name) ?? speaker)
                            .font(.subheadline.bold())
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    if let speakerData = eventAPI.eventSchedule?.speakers[speaker], LocalizeIn(zh: speakerData.zh.bio, en: speakerData.en.bio) != "" {
                        Divider()
                        SpeakerBio(speaker: LocalizeIn(zh: eventAPI.eventSchedule?.speakers[speaker]?.zh.name, en: eventAPI.eventSchedule?.speakers[speaker]?.en.name) ?? speaker,
                                   speakerBio: LocalizeIn(zh: speakerData.zh.bio, en: speakerData.en.bio),
                                   avatarURL: eventAPI.eventSchedule?.speakers[speaker]?.avatar, url: $url, showingAlert: $showingAlert)
                    }
                }
                .padding(.horizontal, 10)
                .background(Color("SectionBackgroundColor"))
                .cornerRadius(8)
                .padding(.bottom, 8)
            }
            .listRowBackground(Color.transparent)
            .listRowSeparator(.hidden)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

fileprivate struct SpeakerBio: View {
    let speaker: String
    let speakerBio: String
    let avatarURL: String?
    @Binding var url: URL
    @Binding var showingAlert: Bool
    @State var isTruncated: Bool = false
    @State var isShowingSpeakerDetail = false
    @State var readSize: CGSize = .zero
    @State var showAvatar = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            TruncableMarkdown(text: speakerBio, font: .footnote, lineLimit: 2) {
                isTruncated = $0
            }
            
            if isTruncated {
                HStack {
                    Spacer()
                    Button("More") {
                        SOCManager.present(isPresented: $isShowingSpeakerDetail) {
                            if readSize.height < UIScreen.main.bounds.height * 0.5 {
                                VStack {
                                    Text(speaker)
                                        .font(.title.bold())
                                    
                                    if !speakerBio.isEmpty {
                                        HStack {
                                            Markdown(speakerBio.tirm())
                                                .markdownStyle(
                                                    MarkdownStyle(font: .footnote)
                                                )
                                                .padding()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(colorScheme == .light ? .white : .black.opacity(0.6))
                                        .cornerRadius(20)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            } else {
                                VStack {
                                    Text(speaker)
                                        .font(.title.bold())
                                    
                                    if !speakerBio.isEmpty {
                                        HStack {
                                            ScrollView {
                                                Markdown(speakerBio.tirm())
                                                    .markdownStyle(
                                                        MarkdownStyle(font: .footnote)
                                                    )
                                                    .padding()
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(colorScheme == .light ? .white : .black.opacity(0.6))
                                        .cornerRadius(20)
                                    }
                                }
                            }
                        }
                    }
                    .font(.footnote)
                }
                .background(
                    VStack {
                        VStack {
                            if !speakerBio.isEmpty {
                                HStack {
                                    Markdown(speakerBio.tirm())
                                        .markdownStyle(
                                            MarkdownStyle(font: .footnote)
                                        )
                                        .padding()
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .readSize { size in readSize = size }
                    }.hidden()
                )
            }
        }
        .padding(.vertical, 8)
    }
}

fileprivate struct DescriptionSection: View {
    
    let description: String
    @Binding var url: URL
    @Binding var showingAlert: Bool
    
    var body: some View {
        Section(header: Text(LocalizedStringKey("SessionIntroduction")).padding(.leading, 10)) {
            Markdown(description.tirm())
                .markdownStyle(
                    MarkdownStyle(font: .footnote)
                )
                .padding()
                //.onOpenMarkdownLink { url in
                //    self.url = url
                //    self.showingAlert = true
                //}
                //.environment(\.openURL, OpenURLAction { url in
                //    self.url = url
                //    self.showingAlert = true
                //    return .handled
                //})
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}
