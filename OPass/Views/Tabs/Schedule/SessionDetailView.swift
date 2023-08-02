//
//  SessionDetailView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/27.
//  2023 OPass.
//

import SwiftUI
import EventKit
import SwiftDate
import OrderedCollections

struct SessionDetailView: View {
    
    let sessionData: Session
    @EnvironmentObject var EventStore: EventStore
    @State private var isCalendarAlertPresented = false
    @State private var isEventEditViewPresented = false
    @State private var isNavigationTitlePresented = false
    @State private var navigationY_Coordinate: CGFloat = .zero
    @Environment(\.colorScheme) var colorScheme
    private var eventStore = EKEventStore()
    private var isLiked: Bool {
        self.EventStore.likedSessions.contains(sessionData.id)
    }
    
    init(_ sessionData: Session) {
        self.sessionData = sessionData
    }
    
    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 0) {
                if sessionData.tags.isNotEmpty, let schedule = EventStore.schedule {
                    TagsSection(tags: schedule.tags)
                        .padding(.bottom, 8)
                        .padding(.top, 3.9)
                }
                
                Text(sessionData.localized().title)
                    .font(.largeTitle.bold())
                    .fixedSize(horizontal: false, vertical: true)
                    .background(GeometryReader { geo in
                        Color.clear
                            .preference(key: TitleY_CoordinatePreferenceKey.self, value: geo.frame(in: .global).maxY)
                    })
                    .onPreferenceChange(TitleY_CoordinatePreferenceKey.self) { y in
                        isNavigationTitlePresented = y < navigationY_Coordinate + 10
                    }
                
                FeatureButtons(sessionData: sessionData)
                    .padding(.vertical)
                
                if let type = sessionData.type {
                    TypeSection(name: EventStore.schedule?.types[type]?.localized().name ?? type)
                        .background(Color("SectionBackgroundColor"))
                        .cornerRadius(8)
                        .padding(.bottom)
                }
                
                PlaceSection(name: EventStore.schedule?.rooms[sessionData.room]?.localized().name ?? sessionData.room)
                    .background(Color("SectionBackgroundColor"))
                    .cornerRadius(8)
                    .padding(.bottom)
                
                TimeSection(sessionData: sessionData)
                    .background(Color("SectionBackgroundColor"))
                    .cornerRadius(8)
                
                if let broadcast = sessionData.broadcast, broadcast.isNotEmpty {
                    BroadcastSection(EventStore.schedule, broadcast: broadcast)
                        .background(Color("SectionBackgroundColor"))
                        .cornerRadius(8)
                        .padding(.top)
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            if sessionData.speakers.isNotEmpty {
                SpeakersSections(sessionData: sessionData)
            }
            
            if sessionData.localized().description != "" {
                DescriptionSection(description: sessionData.localized().description)
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isNavigationTitlePresented {
                ToolbarItem(placement: .principal) {
                    Text(sessionData.localized().title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    SFButton(systemName: "heart\(isLiked ? ".fill" : "")") {
                        UNUserNotification.registeringNotification(
                            id: sessionData.id,
                            title: String(localized: "SessionWillStartIn5Minutes"),
                            content: String(format: String(localized: "SessionWillStartIn5MinutesContent"),
                                            sessionData.en.title,
                                            EventStore.schedule?.rooms[sessionData.room]?.en.name ?? ""),
                            rawTime: sessionData.start,
                            cancel: isLiked
                        )
                        if isLiked {
                            SoundManager.shared.play(sound: .don)
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                            self.EventStore.likedSessions.removeAll { $0 == sessionData.id }
                        } else {
                            SoundManager.shared.play(sound: .din)
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            self.EventStore.likedSessions.append(sessionData.id)
                        }
                    }
                    
                    Menu {
                        Button {
                            Task {
                                if (try? await eventStore.requestAccess(to: .event)) == true {
                                    isEventEditViewPresented.toggle()
                                } else {
                                    isCalendarAlertPresented.toggle()
                                }
                            }
                        } label: {
                            Label("AddToCalendar", systemImage: "calendar.badge.plus")
                        }
                        
                        if let uri = self.sessionData.uri, let url = URL(string: uri) {
                            Button {
                                let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                                UIApplication.topViewController()?.present(av, animated: true)
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .alert("RequestUserPermitCalendar", isPresented: $isCalendarAlertPresented) {
                        Button("Cancel", role: .cancel, action: {})
                        Button("Settigns") {
                            Constants.openInOS(forURL: URL(string: UIApplication.openSettingsURLString)!)
                        }
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
        .sheet(isPresented: $isEventEditViewPresented) {
            EventEditView(
                eventStore: eventStore,
                event: eventStore.createEvent(
                    title: sessionData.localized().title,
                    startDate: sessionData.start.date,
                    endDate: sessionData.end.date,
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
    let tags: OrderedDictionary<String, Tag>
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags.keys, id: \.self) { key in
                    Text(tags[key]?.localized().name ?? key)
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
    
    init(sessionData: Session) {
        features = [
            (sessionData.live, "video", "Live"),
            (sessionData.co_write, "keyboard", "CoWriting"),
            (sessionData.record, "play", "Record"),
            (sessionData.slide, "paperclip", "Slide"),
            (sessionData.qa, "questionmark", "QA")
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
                                    Constants.openInOS(forURL: youtubeUrl)
                                    return false
                                }()) {
                                    Constants.openInAppSafari(forURL: url, style: colorScheme)
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
    
    init(sessionData: Session) {
        self.start = sessionData.start
        self.end = sessionData.end
        self.durationMinute = Int((sessionData.end - sessionData.start) / 60)
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
    
    let schedule: Schedule?
    let broadcast: [String]
    
    init(_ schedule: Schedule?, broadcast: [String]) {
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
            if let name = schedule?.rooms[room]?.localized().name {
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
    
    let sessionData: Session
    @EnvironmentObject var EventStore: EventStore
    
    var body: some View {
        Section(header: Text(LocalizedStringKey("Speakers")).padding(.leading, 10)) {
            ForEach(sessionData.speakers, id: \.self) { speaker in
                SpeakerBlock(
                    speaker: speaker,
                    speakerData: EventStore.schedule?.speakers[speaker]
                )
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

private struct SpeakerBlock: View {
    
    let speaker: String
    let speakerData: Speaker?
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
                Constants.openInAppSafari(forURL: url, style: colorScheme)
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
                                                    Constants.openInAppSafari(forURL: url, style: colorScheme)
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
                                                        Constants.openInAppSafari(forURL: url, style: colorScheme)
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
                Constants.openInAppSafari(forURL: url, style: colorScheme)
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
