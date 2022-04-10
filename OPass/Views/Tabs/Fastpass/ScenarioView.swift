//
//  ScenarioView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/5.
//

import SwiftUI

struct ScenarioView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    @State var isShowingLogOutAlert = false
    
    var body: some View {
        VStack {
            Form {
                FastpassLogoView(eventAPI: eventAPI)
                .frame(height: UIScreen.main.bounds.width * 0.4)
                .listRowBackground(Color.white.opacity(0))
                
                ForEach(eventAPI.eventScenarioStatus?.scenarios.sectionID ?? [], id: \.self) { sectionID in
                    Section(header: Text(sectionID)) {
                        ForEach(eventAPI.eventScenarioStatus?.scenarios.sectionData[sectionID] ?? [], id: \.self) { scenario in
                            Button(action: {
                                
                            }) {
                                VStack {
                                    Text(scenario.display_text.zh).foregroundColor(.black)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Fast Pass").font(.headline)
                    Text(eventAPI.display_name.en).font(.caption).foregroundColor(.gray)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isShowingLogOutAlert.toggle()
                }) { Text("Sign Out").foregroundColor(.red) }
            }
        }
        .alert("Confirm sign out?", isPresented: $isShowingLogOutAlert) {
            Button("Sign Out", role: .destructive) {
                eventAPI.isLogin = false
                eventAPI.accessToken = nil
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
}

struct FastpassLogoView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    
    var body: some View {
        HStack {
            Spacer()
            if let eventLogoData = eventAPI.eventLogo, let eventLogoUIImage = UIImage(data: eventLogoData) {
                Image(uiImage: eventLogoUIImage)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color("LogoColor"))
            } else {
                Text(eventAPI.display_name.en)
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(Color("LogoColor"))
            }
            Spacer()
        }
    }
}

#if DEBUG
struct ScenarioView_Previews: PreviewProvider {
    static var previews: some View {
        ScenarioView(eventAPI: OPassAPIViewModel.mock().eventList[5])
    }
}
#endif
