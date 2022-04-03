//
//  SessionView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//

import SwiftUI
import SwiftDate

struct ScheduleView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    let weekDayName = ["Mon", "Tue", "Wen", "Thr", "Fri", "Sat", "Sun"]
    
    @State var scheduleData = [SessionModel()]
    @State var scheduleDataCollation: [DateInRegion : [SessionModel]] = [DateInRegion():[SessionModel()]]
    @State var scheduleDataUniqueStartDate: [DateInRegion] = [DateInRegion()]
    
    var body: some View {
        VStack {
            if let allScheduleData = eventAPI.eventSchedule {
                VStack(spacing: 0) {
                    if allScheduleData.sessions.count > 1 {
                        HStack(spacing: 10) {
                            ForEach(allScheduleData.sessions, id: \.self) { dayData in
                                Button(action: {
                                    scheduleData = dayData
                                    scheduleDataCollation = Dictionary(grouping: scheduleData, by: { $0.start })
                                    scheduleDataUniqueStartDate = scheduleDataCollation.map({ $0.key }).sorted()
                                }) {
                                    VStack {
                                        Text(
                                            String(weekDayName[dayData[0].start.weekday - 1])
                                            + "\n" +
                                            String(dayData[0].start.day)
                                        )
                                        .foregroundColor(scheduleData == dayData ? Color.white : Color.black)
                                    }
                                    .padding(8)
                                    .background(Color.blue.opacity(scheduleData == dayData ? 1 : 0))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        Divider().padding(.top, 8)
                    }
                    
                    Form {
                        ForEach(scheduleDataUniqueStartDate, id: \.self) { startDate in
                            Section {
                                if let sectionScheduleData = self.scheduleDataCollation[startDate] {
                                    ForEach(sectionScheduleData, id: \.self) { sessionDetail in
                                        if sessionDetail.type != "Ev" {
                                            NavigationLink(destination:
                                                            ScheduleDetailView(eventAPI: eventAPI, scheduleDetail: sessionDetail)
                                            ){
                                                DetailOverView(room: (eventAPI.eventSchedule?.rooms[sessionDetail.room]?.zh.name ?? sessionDetail.room),
                                                               start: sessionDetail.start,
                                                               end: sessionDetail.end,
                                                               title: sessionDetail.zh.title)
                                            }
                                        } else {
                                            DetailOverView(room: (eventAPI.eventSchedule?.rooms[sessionDetail.room]?.zh.name ?? sessionDetail.room),
                                                           start: sessionDetail.start,
                                                           end: sessionDetail.end,
                                                           title: sessionDetail.zh.title)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear(perform: {
                    scheduleData = allScheduleData.sessions[0]
                    scheduleDataCollation = Dictionary(grouping: scheduleData, by: { $0.start })
                    scheduleDataUniqueStartDate = scheduleDataCollation.map({ $0.key }).sorted()
                })
            } else {
                ProgressView("Loading...")
            }
        }
        .task {
            await eventAPI.loadSchedule()
        }
        .navigationTitle("Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                SFButton(systemName: "line.3.horizontal.decrease.circle") {
                    
                }
            }
        }
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
