//
//  SessionDetailView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/27.
//  2022 OPass.
//

import SwiftUI
import EventKit
import SwiftDate

struct SessionDetailView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var eventAPI: EventAPIViewModel
    let sessionDetail: SessionDataModel
    @AppStorage var likedSessions: [String]
    @State var navigationY_Coordinate: CGFloat = .zero
    @State var showingUrlAlert = false
    @State var showingCalendarAlert = false
    @State var showingEventEditView = false
    @State var showingNavigationTitle = false
    private var eventStore = EKEventStore()
    private var isLiked: Bool {
        likedSessions.contains(sessionDetail.id)
    }
    
    init(eventAPI: EventAPIViewModel, detail: SessionDataModel) {
        self._eventAPI = ObservedObject(wrappedValue: eventAPI)
        self.sessionDetail = detail
        self._likedSessions = AppStorage(wrappedValue: [], "liked_sessions", store: UserDefaults(suiteName: eventAPI.event_id))
    }
    
    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 0) {
                if !sessionDetail.tags.isEmpty {
                    TagsSection(tagsID: sessionDetail.tags, tags: eventAPI.eventSchedule?.tags.data ?? [:])
                        .padding(.bottom, 8)
                        .padding(.top, 3.9)
                }
                
                Text(LocalizeIn(zh: sessionDetail.zh, en: sessionDetail.en).title)
                    .font(.largeTitle.bold())
                    .fixedSize(horizontal: false, vertical: true)
                    .background(GeometryReader { geo in
                        Color.clear
                            .preference(key: TitleY_CoordinatePreferenceKey.self, value: geo.frame(in: .global).maxY)
                    })
                    .onPreferenceChange(TitleY_CoordinatePreferenceKey.self) { y in
                        showingNavigationTitle = y < navigationY_Coordinate + 10
                    }
                
                FeatureButtons(sessionDetail: sessionDetail)
                    .padding(.vertical)
                
                if let type = sessionDetail.type {
                    TypeSection(name: LocalizeIn(zh: eventAPI.eventSchedule?.session_types.data[type]?.zh,
                                                 en: eventAPI.eventSchedule?.session_types.data[type]?.en)?.name ?? type)
                    .background(Color("SectionBackgroundColor"))
                    .cornerRadius(8)
                    .padding(.bottom)
                }
                
                PlaceSection(name: LocalizeIn(zh: eventAPI.eventSchedule?.rooms.data[sessionDetail.room]?.zh,
                                              en: eventAPI.eventSchedule?.rooms.data[sessionDetail.room]?.en)?.name ?? sessionDetail.room)
                    .background(Color("SectionBackgroundColor"))
                    .cornerRadius(8)
                    .padding(.bottom)
                
                TimeSection(sessionDetail: sessionDetail)
                    .background(Color("SectionBackgroundColor"))
                    .cornerRadius(8)
                
                if let broadcast = sessionDetail.broadcast, !broadcast.isEmpty {
                    BroadcastSection(eventAPI.eventSchedule, broadcast: broadcast)
                        .background(Color("SectionBackgroundColor"))
                        .cornerRadius(8)
                        .padding(.top)
                }
            }
            .listRowBackground(Color.transparent)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
            if !sessionDetail.speakers.isEmpty {
                SpeakersSections(eventAPI: eventAPI, sessionDetail: sessionDetail)
            }
            
            if let description = LocalizeIn(zh: sessionDetail.zh, en: sessionDetail.en).description, description != "" {
                DescriptionSection(description: description)
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(showingNavigationTitle ? LocalizeIn(zh: sessionDetail.zh, en: sessionDetail.en).title : "")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    SFButton(systemName: "heart\(isLiked ? ".fill" : "")") {
                        UNUserNotification.registeringNotification(
                            id: sessionDetail.id,
                            title: String(localized: "SessionWillStartIn5Minutes"),
                            content: String(format: String(localized: "SessionWillStartIn5MinutesContent"),
                                            sessionDetail.en.title,
                                            eventAPI.eventSchedule?.rooms.data[sessionDetail.room]?.en.name ?? ""),
                            rawTime: sessionDetail.start,
                            cancel: isLiked
                        )
                        if isLiked {
                            SoundManager.shared.play(sound: .don)
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                            likedSessions.removeAll { $0 == sessionDetail.id }
                        } else {
                            SoundManager.shared.play(sound: .din)
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            likedSessions.append(sessionDetail.id)
                        }
                    }
                    
                    Menu {
                        Button {
                            Task {
                                if (try? await eventStore.requestAccess(to: .event)) == true {
                                    showingEventEditView.toggle()
                                } else {
                                    showingCalendarAlert.toggle()
                                }
                            }
                        } label: {
                            Label("AddToCalendar", systemImage: "calendar.badge.plus")
                        }
                        
                        if let uri = self.sessionDetail.uri, let url = URL(string: uri), let av = UIActivityViewController(activityItems: [url], applicationActivities: nil) {
                            Button {
                                UIApplication.topViewController()?.present(av, animated: true)
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .alert("RequestUserPermitCalendar", isPresented: $showingCalendarAlert) {
                        Button("Cancel", role: .cancel, action: {})
                        Button("Settings", action: {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        })
                    }
                }
                .background(GeometryReader { geo in
                    Color.clear
                        .preference(key: navigationY_CoordinatePreferenceKey.self, value: geo.frame(in: .global).maxY)
                })
                .onPreferenceChange(navigationY_CoordinatePreferenceKey.self) { y in
                    self.navigationY_Coordinate = y
                }
            }
            
        }
        .sheet(isPresented: $showingEventEditView) {
            EventEditView(
                eventStore: eventStore,
                event: eventStore.createEvent(
                    title: LocalizeIn(zh: sessionDetail.zh, en: sessionDetail.zh).title,
                    startDate: sessionDetail.start.date,
                    endDate: sessionDetail.end.date,
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

private struct TagsSection: View {
    
    @Environment(\.colorScheme) var colorScheme
    let tagsID: [String]
    let tags: [String : Name_DescriptionPair]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tagsID, id: \.self) { tagID in
                    Text(LocalizeIn(zh: tags[tagID]?.zh, en: tags[tagID]?.en)?.name ?? tagID)
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
private struct FeatureButtons: View {
    
    @Environment(\.colorScheme) var colorScheme
    let features: [(String, String, String)]
    let buttonSize = CGFloat(62)
    
    init(sessionDetail: SessionDataModel) {
        features = [
            (sessionDetail.live, "video", "Live"),
            (sessionDetail.co_write, "keyboard", "CoWriting"),
            (sessionDetail.record, "play", "Record"),
            (sessionDetail.slide, "paperclip", "Slide"),
            (sessionDetail.qa, "questionmark", "QA")
        ].filter { (url, _, _) in url != nil } as! [(String, String, String)]
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(features, id: \.0, content: { (url, systemImageName, text) in
                    if let url = URL(string: url) {
                        VStack {
                            Button {
                                Constants.OpenInAppSafari(forURL: url, style: colorScheme)
                            } label: {
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
                    }
                })
            }
        }
    }
}

private struct TypeSection: View {
    
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

private struct PlaceSection: View {
    
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

private struct TimeSection: View {
    
    let start: DateInRegion
    let end: DateInRegion
    let durationMinute: Int
    
    init(sessionDetail: SessionDataModel) {
        self.start = sessionDetail.start
        self.end = sessionDetail.end
        self.durationMinute = Int((sessionDetail.end - sessionDetail.start) / 60)
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

private struct BroadcastSection: View {
    
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
                zh: eventSchedule?.rooms.data[room]?.zh.name,
                en: eventSchedule?.rooms.data[room]?.en.name
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

private struct SpeakersSections: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    let sessionDetail: SessionDataModel
    
    var body: some View {
        Section(header: Text(LocalizedStringKey("Speakers")).padding(.leading, 10)) {
            ForEach(sessionDetail.speakers, id: \.self) { speaker in
                SpeakerBlock(
                    speaker: speaker,
                    speakerData: eventAPI.eventSchedule?.speakers.data[speaker]
                )
            }
            .listRowBackground(Color.transparent)
            .listRowSeparator(.hidden)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

private struct SpeakerBlock: View {
    
    let speaker: String
    let speakerData: SpeakerModel?
    @State var avatarImage: Image? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                AsyncImage(url: URL(string: speakerData?.avatar ?? ""), transaction: .init(animation: .spring())) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .renderingMode(.original)
                            .resizable().scaledToFill()
                            .onAppear { avatarImage = image }
                    default:
                        Image(systemName: "person.crop.circle.fill")
                            .resizable().scaledToFit()
                            .foregroundColor(.gray)
                    }
                }
                .clipShape(Circle())
                .frame(width: 30, height: 30)
                
                Text(LocalizeIn(zh: speakerData?.zh, en: speakerData?.en)?.name ?? speaker)
                    .font(.subheadline.bold())
                Spacer()
            }
            .padding(.vertical, 8)
            if let data = speakerData, LocalizeIn(zh: speakerData?.zh, en: speakerData?.en)?.bio != "" {
                Divider()
                SpeakerBio(
                    speaker: LocalizeIn(zh: data.zh, en: data.en).name,
                    speakerBio: LocalizeIn(zh: data.zh, en: data.en).bio,
                    avatarImage: avatarImage
                )
            }
        }
        .padding(.horizontal, 10)
        .background(Color("SectionBackgroundColor"))
        .cornerRadius(8)
        .padding(.bottom, 8)
    }
}

private struct SpeakerBio: View {
    let speaker: String
    let speakerBio: String
    let avatarImage: Image?
    @State private var isTruncated: Bool = false
    @State private var isShowingSpeakerDetail = false
    @State private var showAvatar = false
    @State private var intrinsicSize: CGSize = .zero
    @State private var truncatedSize: CGSize = .zero
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            Markdown(speakerBio, font: .footnote) { url in
                Constants.OpenInAppSafari(forURL: url, style: colorScheme)
            }
            .lineSpacing(4)
            .lineLimit(2)
            .readSize { size in
                truncatedSize = size
                isTruncated = truncatedSize != intrinsicSize
            }
            .background(
                Markdown(speakerBio, font: .footnote)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden()
                    .readSize { size in
                        intrinsicSize = size
                        isTruncated = truncatedSize != intrinsicSize
                    }
            )
            
            if isTruncated {
                HStack {
                    Spacer()
                    Button("More") {
                        SOCManager.present(isPresented: $isShowingSpeakerDetail, style: colorScheme == .dark ? .dark : .light) {
                            VStack {
                                Group {
                                    if let image = avatarImage {
                                        image
                                            .renderingMode(.original)
                                            .resizable().scaledToFill()
                                    } else {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable().scaledToFit()
                                            .foregroundColor(.gray)
                                    }
                                }
                                .clipShape(Circle())
                                .frame(width: UIScreen.main.bounds.width * 0.25,
                                       height: UIScreen.main.bounds.width * 0.25)
                                .padding(.bottom, 2)
                                
                                Text(speaker)
                                    .font(.title.bold())
                                
                                if intrinsicSize.height < UIScreen.main.bounds.height * 0.5 {
                                    VStack {
                                        HStack {
                                            Markdown(speakerBio, font: .footnote) { url in
                                                SOCManager.dismiss(isPresented: $isShowingSpeakerDetail)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
                                                    Constants.OpenInAppSafari(forURL: url, style: colorScheme)
                                                }
                                            }
                                            .lineSpacing(4)
                                            .padding()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(colorScheme == .light ? .white : .black.opacity(0.6))
                                        .cornerRadius(20)
                                    }.frame(maxWidth: .infinity)
                                } else {
                                    VStack {
                                        HStack {
                                            ScrollView {
                                                Markdown(speakerBio, font: .footnote) { url in
                                                    SOCManager.dismiss(isPresented: $isShowingSpeakerDetail)
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
                                                        Constants.OpenInAppSafari(forURL: url, style: colorScheme)
                                                    }
                                                }
                                                .lineSpacing(4)
                                                .padding()
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(colorScheme == .light ? .white : .black.opacity(0.6))
                                        .cornerRadius(20)
                                    }.frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.5)
                                }
                            }
                        }
                    }
                    .font(.footnote)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

private struct DescriptionSection: View {
    
    let description: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Section(header: Text(LocalizedStringKey("SessionIntroduction")).padding(.leading, 10)) {
            Markdown(description, font: .footnote) { url in
                Constants.OpenInAppSafari(forURL: url, style: colorScheme)
            }
            .lineSpacing(4)
            .padding()
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

private struct TitleY_CoordinatePreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

private struct navigationY_CoordinatePreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
//
