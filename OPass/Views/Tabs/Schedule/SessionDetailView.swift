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
    
    @ObservedObject var eventAPI: EventAPIViewModel
    let sessionDetail: SessionDataModel
    @Environment(\.colorScheme) var colorScheme
    @State var navigationY_Coordinate: CGFloat = .zero
    @State var showingUrlAlert = false
    @State var showingCalendarAlert = false
    @State var showingEventEditView = false
    @State var showingNavigationTitle = false
    private var eventStore = EKEventStore()
    private var isLiked: Bool {
        self.eventAPI.liked_sessions.contains(sessionDetail.id)
    }
    
    init(_ eventAPI: EventAPIViewModel, detail: SessionDataModel) {
        self.eventAPI = eventAPI
        self.sessionDetail = detail
    }
    
    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 0) {
                if sessionDetail.tags.isNotEmpty {
                    TagsSection(tagsID: sessionDetail.tags, tags: eventAPI.schedule?.tags.data ?? [:])
                        .padding(.bottom, 8)
                        .padding(.top, 3.9)
                }
                
                Text(sessionDetail.localized().title)
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
                    TypeSection(name: eventAPI.schedule?.session_types.data[type]?.localized().name ?? type)
                        .background(Color("SectionBackgroundColor"))
                        .cornerRadius(8)
                        .padding(.bottom)
                }
                
                PlaceSection(name: eventAPI.schedule?.rooms.data[sessionDetail.room]?.localized().name ?? sessionDetail.room)
                    .background(Color("SectionBackgroundColor"))
                    .cornerRadius(8)
                    .padding(.bottom)
                
                TimeSection(sessionDetail: sessionDetail)
                    .background(Color("SectionBackgroundColor"))
                    .cornerRadius(8)
                
                if let broadcast = sessionDetail.broadcast, broadcast.isNotEmpty {
                    BroadcastSection(eventAPI.schedule, broadcast: broadcast)
                        .background(Color("SectionBackgroundColor"))
                        .cornerRadius(8)
                        .padding(.top)
                }
            }
            .listRowBackground(Color.transparent)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            if sessionDetail.speakers.isNotEmpty {
                SpeakersSections(eventAPI: eventAPI, sessionDetail: sessionDetail)
            }
            
            if let description = sessionDetail.localized().description, description != "" {
                DescriptionSection(description: description)
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(showingNavigationTitle ? sessionDetail.localized().title : "")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    SFButton(systemName: "heart\(isLiked ? ".fill" : "")") {
                        UNUserNotification.registeringNotification(
                            id: sessionDetail.id,
                            title: String(localized: "SessionWillStartIn5Minutes"),
                            content: String(format: String(localized: "SessionWillStartIn5MinutesContent"),
                                            sessionDetail.en.title,
                                            eventAPI.schedule?.rooms.data[sessionDetail.room]?.en.name ?? ""),
                            rawTime: sessionDetail.start,
                            cancel: isLiked
                        )
                        if isLiked {
                            SoundManager.shared.play(sound: .don)
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                            self.eventAPI.liked_sessions.removeAll { $0 == sessionDetail.id }
                        } else {
                            SoundManager.shared.play(sound: .din)
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            self.eventAPI.liked_sessions.append(sessionDetail.id)
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
                        
                        if let uri = self.sessionDetail.uri, let url = URL(string: uri) {
                            Button {
                                let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
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
                            Constants.OpenInOS(forURL: URL(string: UIApplication.openSettingsURLString)!)
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
                    title: sessionDetail.localized().title,
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
                    Text(tags[tagID]?.localized().name ?? tagID)
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
                                if ({
                                    guard let regex = try? NSRegularExpression(
                                        pattern: "(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)",
                                        options: .caseInsensitive
                                    ) else { return true }
                                    guard let match = regex.firstMatch(
                                        in: url.absoluteString,
                                        options: .reportProgress,
                                        range: NSRange(location: 0, length: url.absoluteString.count)
                                    ) else { return true }
                                    guard let youtubeUrl = URL(
                                        string:"youtube://\((url.absoluteString as NSString).substring(with: match.range(at: 0)))")
                                    else { return true }
                                    guard UIApplication.shared.canOpenURL(youtubeUrl) else { return true }
                                    Constants.OpenInOS(forURL: youtubeUrl)
                                    return false
                                }()) {
                                    Constants.OpenInAppSafari(forURL: url, style: colorScheme)
                                }
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
    
    let schedule: ScheduleModel?
    let broadcast: [String]
    
    init(_ schedule: ScheduleModel?, broadcast: [String]) {
        self.schedule = schedule
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
            if let name = schedule?.rooms.data[room]?.localized().name {
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
                    speakerData: eventAPI.schedule?.speakers.data[speaker]
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
                
                Text(speakerData?.localized().name ?? speaker)
                    .font(.subheadline.bold())
                Spacer()
            }
            .padding(.vertical, 8)
            if let data = speakerData, data.localized().bio.isNotEmpty {
                Divider()
                SpeakerBio(
                    speaker: data.localized().name,
                    speakerBio: data.localized().bio,
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
