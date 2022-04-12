//
//  EventListView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//  2022 OPass.
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
                                .foregroundColor(Color("LogoColor"))
                                .aspectRatio(contentMode: .fit)
                                .padding(.horizontal, 3)
                                .frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.width * 0.15)
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
            .navigationTitle("Select Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
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
