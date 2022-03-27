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
                                                            ScheduleDetailView(
                                                                scheduleDetail: sessionDetail,
                                                                speakersData: allScheduleData.speakers,
                                                                roomsData: allScheduleData.rooms,
                                                                tagsData: allScheduleData.tags
                                                            )
                                            ){
                                                VStack {
                                                    Text(sessionDetail.zh.title)
                                                }
                                            }
                                        } else {
                                            Text(sessionDetail.zh.title)
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

#if DEBUG
struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView(eventAPI: OPassAPIViewModel.mock().eventList[5])
            .environmentObject(OPassAPIViewModel.mock())
    }
}
#endif
