//
//  EventListView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//

import SwiftUI

struct EventListView: View {
    
    @AppStorage("CurrentEvent") var currentEvent = "NULL"
    @EnvironmentObject var OPassAPI: OPassAPIViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                ForEach(OPassAPI.eventList, id: \.event_id) { list in
                    Button(action: {
                        OPassAPI.currentEventAPI = list
                        currentEvent = list.event_id
                        dismiss()
                    }) {
                        HStack {
                            URLImage(urlString: list.logo_url)
                                .aspectRatio(contentMode: .fit)
                                .padding(3)
                                .frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.width * 0.15)
                                .background(Color.purple)
                                .cornerRadius(5)
                            
                            Text(list.display_name.zh)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("選擇活動")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("關閉") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    SFButton(systemName: "arrow.clockwise") {
                        Task {
                            await OPassAPI.loadEventList()
                        }
                    }
                }
            }
        }
        .task {
            await OPassAPI.loadEventList()
        }
    }
}

#if DEBUG
struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
            .environmentObject(OPassAPIViewModel.mock())
    }
}
#endif

/*
 ScrollView {
     VStack {
         ForEach(OPassAPI.eventList, id: \.event_id) { list in
             Button(action: {
                 OPassAPI.currentEventAPI = list
                 currentEvent = list.event_id
                 dismiss()
             }) {
                 VStack(spacing: 0) {
                     HStack {
                         URLImage(urlString: list.logo_url)
                             .padding(10)
                             .aspectRatio(contentMode: .fit)
                     }
                     .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.35)
                     .background(Color.purple)
                     Text(list.display_name.zh)
                         .font(.title)
                         .padding()
                 }
                 .foregroundColor(Color.black)
                 .frame(width: UIScreen.main.bounds.width * 0.9)
                 .background(Color.white)
                 .cornerRadius(10)
                 .shadow(radius: 10)
                 .padding()
             }
         }
     }
 }
 .navigationTitle("選擇活動")
 .navigationBarTitleDisplayMode(.inline)
 .toolbar {
     ToolbarItem(placement: .navigationBarLeading) {
         Button("關閉") {
             dismiss()
         }
     }
     ToolbarItem(placement: .navigationBarTrailing) {
         SFButton(systemName: "arrow.clockwise") {
             Task {
                 await OPassAPI.loadEventList()
             }
         }
     }
 }
*/
