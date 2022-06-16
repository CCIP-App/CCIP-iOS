//
//  ScheduleDetailView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/27.
//  2022 OPass.
//

import SwiftUI
import EventKit
import SwiftDate
import MarkdownUI
import SlideOverCard
import BetterSafariView

struct ScheduleDetailView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var eventAPI: EventAPIViewModel
    let scheduleDetail: SessionDataModel
    @AppStorage var likedSessions: [String]
    @State var isShowingSpeakerDetail: Bool = false
    @State var showSpeaker: String?
    @State var url: URL = URL(string: "https://opass.app")!
    @State var showingUrlAlert = false
    @State var showingSafari = false
    @State var showingEventEditView = false
    private var eventStore = EKEventStore()
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
                
                if let broadcast = scheduleDetail.broadcast, !broadcast.isEmpty {
                    BroadcastSection(eventAPI.eventSchedule, broadcast: broadcast)
                        .background(Color("SectionBackgroundColor"))
                        .cornerRadius(8)
                        .padding(.top)
                }
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
                .preferredBarAccentColor(colorScheme == .dark ? .black : .white)
                .dismissButtonStyle(.done)
            }
                
            if scheduleDetail.speakers.count != 0 {
                SpeakersSections(
                    eventAPI: eventAPI,
                    scheduleDetail: scheduleDetail,
                    url: $url, showingAlert: $showingUrlAlert
                )
            }
            
            if let description = scheduleDetail.zh.description, description != "" {
                DescriptionSection(description: description,
                                   url: $url, showingAlert: $showingUrlAlert)
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
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
                    
                    Menu {
                        Button {
                            Task {
                                if (try? await eventStore.requestAccess(to: .event)) == true {
                                    showingEventEditView.toggle()
                                }
                            }
                        } label: {
                            Label("AddToCalendar", systemImage: "calendar.badge.plus")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEventEditView) {
            EventEditView(
                eventStore: eventStore,
                event: eventStore.createEvent(
                    title: LocalizeIn(zh: scheduleDetail.zh.title, en: scheduleDetail.zh.title),
                    startDate: scheduleDetail.start.date,
                    endDate: scheduleDetail.end.date,
                    alertOffset: -300 // T minus 5 minutes
                )
            )
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
        ScrollView(.horizontal, showsIndicators: false) {
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
            (scheduleDetail.co_write, "keyboard", "CoWriting"),
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
                .resizable().scaledToFit()
                .foregroundColor(Color(red: 1, green: 204/255, blue: 0, opacity: 1))
                .padding()
                .frame(width: 50, height: 50)
            VStack(alignment: .leading, spacing: 0) {
                Text(LocalizedStringKey("Type")).font(.caption)
                    .foregroundColor(.gray)
                Text(name)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 7)
            Spacer()
        }
    }
}

fileprivate struct PlaceSection: View {
    
    let name: String
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "map")
                .resizable().scaledToFit()
                .foregroundColor(Color.blue)
                .padding()
                .frame(width: 50, height: 50)
            VStack(alignment: .leading, spacing: 0) {
                Text(LocalizedStringKey("Place")).font(.caption)
                    .foregroundColor(.gray)
                Text(name)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 7)
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
            Image(systemName: "clock")
                .resizable().scaledToFit()
                .foregroundColor(Color.red)
                .padding()
                .frame(width: 50, height: 50)
            VStack(alignment: .leading, spacing: 0) {
                Text(String(format: "%d/%d/%d", start.year, start.month, start.day))
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(String(format: String(localized: "TimeWithLengthContent"), start.hour, start.minute, end.hour, end.minute, durationMinute))
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 7)
            Spacer()
        }
    }
}

fileprivate struct BroadcastSection: View {
    
    let eventSchedule: ScheduleModel?
    let broadcast: [String]
    
    init(_ eventSchedule: ScheduleModel?, broadcast: [String]) {
        self.eventSchedule = eventSchedule
        self.broadcast = broadcast
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "megaphone")
                .resizable().scaledToFit()
                .foregroundColor(Color.orange)
                .padding()
                .frame(width: 50, height: 50)
            VStack(alignment: .leading, spacing: 0) {
                Text(LocalizedStringKey("Broadcast"))
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(renderRoomsString())
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 7)
            Spacer()
        }
    }
    
    private func renderRoomsString() -> String {
        var result = ""
        for (offset, room) in broadcast.enumerated() {
            if let name = LocalizeIn(
                zh: eventSchedule?.rooms[room]?.zh.name,
                en: eventSchedule?.rooms[room]?.en.name
            ) {
                result.append(name)
                if offset < broadcast.count - 1 {
                    result.append(LocalizeIn(zh: "、", en: ", "))
                }
            }
        }
        return result
    }
}

fileprivate struct SpeakersSections: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    let scheduleDetail: SessionDataModel
    @Binding var url: URL
    @Binding var showingAlert: Bool
    
    var body: some View {
        Section(header: Text(LocalizedStringKey("Speakers")).padding(.leading, 10)) {
            ForEach(scheduleDetail.speakers, id: \.self) { speaker in
                SpeakerBlock(
                    speaker: speaker,
                    speakerData: eventAPI.eventSchedule?.speakers[speaker],
                    url: $url, showingAlert: $showingAlert
                )
            }
            .listRowBackground(Color.transparent)
            .listRowSeparator(.hidden)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

fileprivate struct SpeakerBlock: View {
    
    let speaker: String
    let speakerData: SpeakerModel?
    @Binding var url: URL
    @Binding var showingAlert: Bool
    @State var avatarData: Data?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                if let avatarURL = speakerData?.avatar {
                    Group {
                        if let data = avatarData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .renderingMode(.original)
                                .resizable().scaledToFill()
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable().scaledToFit()
                                .foregroundColor(.gray)
                                .onAppear {
                                    fetchAvatarData(url: avatarURL)
                                }
                        }
                    }
                    .clipShape(Circle())
                    .frame(width: 30, height: 30)
                }
                
                Text(LocalizeIn(zh: speakerData?.zh.name, en: speakerData?.en.name) ?? speaker)
                    .font(.subheadline.bold())
                Spacer()
            }
            .padding(.vertical, 8)
            if let data = speakerData, LocalizeIn(zh: speakerData?.zh.bio, en: speakerData?.en.bio) != "" {
                Divider()
                SpeakerBio(speaker: LocalizeIn(zh: data.zh.name, en: data.en.name),
                           speakerBio: LocalizeIn(zh: data.zh.bio, en: data.en.bio),
                           avatarData: avatarData, url: $url, showingAlert: $showingAlert)
            }
        }
        .padding(.horizontal, 10)
        .background(Color("SectionBackgroundColor"))
        .cornerRadius(8)
        .padding(.bottom, 8)
    }
    
    private func fetchAvatarData(url urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid PNG URL")
            return
        }
            
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            self.avatarData = data
        }
        task.resume()
    }
}

fileprivate struct SpeakerBio: View {
    let speaker: String
    let speakerBio: String
    let avatarData: Data?
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
                        SOCManager.present(isPresented: $isShowingSpeakerDetail, style: colorScheme == .dark ? .dark : .light) {
                            VStack {
                                if let data = avatarData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .renderingMode(.original)
                                        .resizable().scaledToFill()
                                        .clipShape(Circle())
                                        .frame(width: UIScreen.main.bounds.width * 0.25,
                                               height: UIScreen.main.bounds.width * 0.25)
                                        .padding(.bottom, 2)
                                }
                                
                                Text(speaker)
                                    .font(.title.bold())
                                
                                if readSize.height < UIScreen.main.bounds.height * 0.5 {
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
                                            .background(colorScheme == .light ? .white : .black.opacity(0.6))
                                            .cornerRadius(20)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                } else {
                                    VStack {
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
                                    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.5)
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
