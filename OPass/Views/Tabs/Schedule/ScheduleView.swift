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
    @State var selectDayIndex = 0
    @State var filterIndex = 0
    @State var filterWithTag: String = ""
    
    init(eventAPI: EventAPIViewModel) {
        _eventAPI = ObservedObject(wrappedValue: eventAPI)
        _likedSessions = AppStorage(wrappedValue: [], "liked_sessions", store: UserDefaults(suiteName: eventAPI.event_id))
    }
    
    var body: some View {
        VStack {
            if let allScheduleData = eventAPI.eventSchedule {
                VStack(spacing: 0) {
                    if allScheduleData.sessions.count > 1 {
                        SelectDayView(selectDayIndex: $selectDayIndex, sessions: allScheduleData.sessions)
                    }
                    
                    Form {
                        ForEach(allScheduleData.sessions[selectDayIndex].header, id: \.self) { header in
                            if let filteredData = allScheduleData.sessions[selectDayIndex].datas[header]?.filter { session in
                                switch filterIndex {
                                case 1: return likedSessions.contains(session.id)
                                case 2: return session.tags.contains(filterWithTag)
                                default: return true
                                }
                            }, !filteredData.isEmpty {
                                Section {
                                    ForEach(filteredData.sorted(by: { $0.end < $1.end }), id: \.self.id) { sessionDetail in
                                        if sessionDetail.type != "Ev" {
                                            NavigationLink(
                                                destination: ScheduleDetailView(eventAPI: eventAPI,
                                                                                scheduleDetail: sessionDetail)
                                            ){
                                                DetailOverView(
                                                    room: (eventAPI.eventSchedule?.rooms[sessionDetail.room]?.zh.name ?? sessionDetail.room),
                                                    start: sessionDetail.start,
                                                    end: sessionDetail.end,
                                                    title: sessionDetail.zh.title)
                                            }
                                        } else {
                                            DetailOverView(
                                                room: (eventAPI.eventSchedule?.rooms[sessionDetail.room]?.zh.name ?? sessionDetail.room),
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
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .task {
            await eventAPI.loadSchedule() //TODO: need optimize
        }
        .navigationTitle("Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Picker(selection: $filterIndex, label: EmptyView()) {
                        HStack {
                            Text("所有議程")
                            Spacer()
                            Image(systemName: "list.bullet")
                        }
                        .tag(0)
                        HStack {
                            Text("喜歡")
                            Spacer()
                            Image(systemName: "heart\(filterIndex == 1 ? ".fill" : "")")
                        }
                        .tag(1)
                        if let tags = eventAPI.eventSchedule?.tags {
                            Menu {
                                Picker(selection: $filterWithTag, label: EmptyView()) {
                                    ForEach(tags.id, id: \.self) { id in
                                        Text(tags.data[id]?.zh.name ?? id)
                                        .tag(id)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("標籤")
                                    Spacer()
                                    Image(systemName: "tag\(filterIndex == 2 ? ".fill" : "")")
                                }
                            }
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                    .onChange(of: filterIndex) { value in
                        if value == 1 || value == 0 { filterWithTag = "" }
                    }
                    .onChange(of: filterWithTag) { value in
                        if value != "" { filterIndex = 2 }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle\(filterIndex == 0 ? "" : ".fill")")
                }
            }
        }
    }
}

fileprivate struct SelectDayView: View {
    
    @Binding var selectDayIndex: Int
    let sessions: [SessionModel]
    
    let weekDayName = ["Mon", "Tue", "Wen", "Thr", "Fri", "Sat", "Sun"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                ForEach(0 ..< sessions.count, id: \.self) { index in
                    Button(action: {
                        selectDayIndex = index
                    }) {
                        VStack {
                            Text(
                                String(weekDayName[sessions[index].header[0].weekday - 1])
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
        ScheduleView(eventAPI: OPassAPIViewModel.mock().eventList[5])
            .environmentObject(OPassAPIViewModel.mock())
    }
}
#endif
