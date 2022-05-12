//
//  ScheduleView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//  2022 OPass.
//

import SwiftUI
import SwiftDate

struct ScheduleView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    @AppStorage var likedSessions: [String]
    let display_text: DisplayTextModel
    @State var selectDayIndex = 0
    @State var filter = Filter.all
    @State var isError = false
    
    init(eventAPI: EventAPIViewModel) {
        self.eventAPI = eventAPI
        _likedSessions = AppStorage(wrappedValue: [], "liked_sessions", store: UserDefaults(suiteName: eventAPI.event_id))
        self.display_text = eventAPI.eventSettings.feature(ofType: .schedule).display_text
    }
    
    var body: some View {
        VStack {
            if !isError {
                if let allScheduleData = eventAPI.eventSchedule {
                    VStack(spacing: 0) {
                        if allScheduleData.sessions.count > 1 {
                            SelectDayView(selectDayIndex: $selectDayIndex, sessions: allScheduleData.sessions)
                        }
                        
                        Form {
                            ForEach(allScheduleData.sessions[selectDayIndex].header, id: \.self) { header in
                                if let filteredData = allScheduleData.sessions[selectDayIndex].data[header]?.filter { session in
                                    switch filter {
                                        case .liked: return likedSessions.contains(session.id)
                                        case .tag(let tag): return session.tags.contains(tag)
                                        default: return true
                                    }
                                }, !filteredData.isEmpty {
                                    Section {
                                        ForEach(filteredData.sorted(by: { $0.end < $1.end }), id: \.id) { sessionDetail in
                                            if sessionDetail.type != "Ev" {
                                                NavigationLink(
                                                    destination: ScheduleDetailView(eventAPI: eventAPI,
                                                                                    scheduleDetail: sessionDetail)
                                                ){
                                                    DetailOverView(
                                                        room: (LocalizeIn (
                                                            zh: eventAPI.eventSchedule?.rooms[sessionDetail.room]?.zh.name,
                                                            en: eventAPI.eventSchedule?.rooms[sessionDetail.room]?.en.name
                                                        ) ?? sessionDetail.room),
                                                        start: sessionDetail.start,
                                                        end: sessionDetail.end,
                                                        title: sessionDetail.zh.title)
                                                }
                                            } else {
                                                DetailOverView(
                                                    room: (LocalizeIn (
                                                        zh: eventAPI.eventSchedule?.rooms[sessionDetail.room]?.zh.name,
                                                        en: eventAPI.eventSchedule?.rooms[sessionDetail.room]?.en.name
                                                    ) ?? sessionDetail.room),
                                                    start: sessionDetail.start,
                                                    end: sessionDetail.end,
                                                    title: sessionDetail.zh.title)
                                            }
                                        }
                                    }
                                    .listRowInsets(.init(top: 10, leading: 15, bottom: 10, trailing: 15))
                                }
                            }
                        }
                        .refreshable { try? await eventAPI.loadSchedule() }
                    }
                } else {
                    ProgressView(LocalizedStringKey("Loading"))
                        .task {
                            do { try await eventAPI.loadSchedule() }
                            catch { isError = true }
                        }
                }
            } else {
                ErrorWithRetryView {
                    self.isError = false
                    Task {
                        do { try await eventAPI.loadSchedule() }
                        catch { self.isError = true }
                    }
                }
            }
        }
        .navigationTitle(LocalizeIn(zh: display_text.zh, en: display_text.en))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Picker(selection: $filter, label: EmptyView()) {
                        HStack {
                            Text(LocalizedStringKey("AllSessions"))
                            Spacer()
                            Image(systemName: "list.bullet")
                        }
                        .tag(Filter.all)
                        HStack {
                            Text(LocalizedStringKey("Favorite"))
                            Spacer()
                            Image(systemName: "heart\(filter == .liked ? ".fill" : "")")
                        }
                        .tag(Filter.liked)
                        if let tags = eventAPI.eventSchedule?.tags {
                            Menu {
                                Picker(selection: $filter, label: EmptyView()) {
                                    ForEach(tags.id, id: \.self) { id in
                                        Text(LocalizeIn(zh: tags.data[id]?.zh.name, en: tags.data[id]?.en.name) ?? id)
                                            .tag(Filter.tag(id))
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(LocalizedStringKey("Tags"))
                                    Spacer()
                                    switch filter {
                                        case .tag(_):
                                            Image(systemName: "tag.fill")
                                        default:
                                            Image(systemName: "tag")
                                    }
                                }
                            }
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle\(filter == .all ? "" : ".fill")")
                }
            }
        }
    }
}

enum Filter: Hashable {
    case all, liked
    case tag(String)
}

fileprivate struct SelectDayView: View {
    
    @Binding var selectDayIndex: Int
    let sessions: [SessionModel]
    
    let weekDayName = ["MON", "TUE", "WEN", "THR", "FRI", "SAT", "SUN"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                ForEach(0 ..< sessions.count, id: \.self) { index in
                    Button(action: {
                        selectDayIndex = index
                    }) {
                        VStack {
                            Text(
                                String(localized: String.LocalizationValue(weekDayName[sessions[index].header[0].weekday - 1]))
                                + "\n" +
                                String(sessions[index].header[0].day)
                            )
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(index == selectDayIndex ? Color.white : Color.black)
                        }
                        .padding(8)
                        .background(Color.blue.opacity(index == selectDayIndex ? 1 : 0))
                        .cornerRadius(10)
                    }
                }
            }
            Divider().padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
    }
}

fileprivate struct DetailOverView: View {
    
    let room: String,
        start: DateInRegion,
        end: DateInRegion,
        title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack() {
                Text(room)
                    .font(.caption2)
                    .padding(.vertical, 1)
                    .padding(.horizontal, 8)
                    .foregroundColor(.white)
                    .background(.blue)
                    .cornerRadius(5)
                
                Text(String(format: "%d:%02d ~ %d:%02d", start.hour, start.minute, end.hour, end.minute))
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
            Text(title)
                .lineLimit(2)
        }
    }
}

#if DEBUG
struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView(eventAPI: OPassAPIViewModel.mock().currentEventAPI!)
            .environmentObject(OPassAPIViewModel.mock())
    }
}
#endif
