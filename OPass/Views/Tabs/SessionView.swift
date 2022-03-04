//
//  SessionView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//

import SwiftUI

struct SessionView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    @State var selectDayData = [SessionModel()]
    
    var body: some View {
        //Only for API Testing
        
        //Current design performance veryyyyyyyy bad. 'Pre-draw' session list view in future
        VStack {
            if let allData = eventAPI.eventSession {
                //Select date list view
                HStack(spacing: 10) {
                    ForEach(allData.sessions, id: \.self) { dayData in
                        Button(action: {
                            selectDayData = dayData
                        }) {
                            VStack {
                                Text(String(dayData[0].start.month) + "/" + String(dayData[0].start.day))
                                    .foregroundColor(Color.white)
                            }
                            .padding(5)
                            .background(Color.blue.opacity(selectDayData == dayData ? 1 : 0))
                            .cornerRadius(5)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.purple)
                .onAppear(perform: {
                    selectDayData = allData.sessions[0]
                })
                
                //Session list view
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(selectDayData, id: \.self) { currentSession in
                            VStack {
                                Text(currentSession.zh.title)
                            }
                            .padding(5)
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                            .background(Color.green)
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .task {
            await eventAPI.loadEventSession()
        }
    }
}

#if DEBUG
struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView(eventAPI: OPassAPIViewModel.mock().eventList[5])
            .environmentObject(OPassAPIViewModel.mock())
    }
}
#endif
