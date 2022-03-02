//
//  EventListView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//

import SwiftUI

struct EventListView: View {
    
    @EnvironmentObject var OPassAPI: OPassAPIModels
    
    var body: some View {
        //Only for API Testing
        ScrollView {
            VStack {
                ForEach(OPassAPI.eventList, id: \.self) { list in
                    Button(action: {
                        Task {
                            await OPassAPI.loadEventSettings_Logo(event_id: list.event_id)
                        }
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
        .task {
            await OPassAPI.loadEventList()
        }
    }
}

#if DEBUG
struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
            .environmentObject(OPassAPIModels.mock())
    }
}
#endif
