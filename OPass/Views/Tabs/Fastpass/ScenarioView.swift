//
//  ScenarioView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/5.
//  2022 OPass.
//

import SwiftUI
import SwiftDate

struct ScenarioView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    @State var isShowingLogOutAlert = false
    @State var isShowingDisableAlert = false
    @State var alertString = ""
    @State var sheetScenarioData: ScenarioDataModel?
    
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
                                if scenario.used == nil {
                                    if let errorText = scenario.disabled {
                                        alertString = errorText
                                        isShowingDisableAlert.toggle()
                                    } else if !DateInRegion().isInRange(date: scenario.available_time,
                                                                        and: scenario.expire_time, orEqual: false,
                                                                        granularity: .second) {
                                        alertString = String(format: "Only available at\n%d/%d/%d %d:%02d ~ %d/%d/%d %d:%02d",
                                                             scenario.available_time.year, scenario.available_time.month,
                                                             scenario.available_time.day, scenario.available_time.hour,
                                                             scenario.available_time.minute, scenario.expire_time.year,
                                                             scenario.expire_time.month, scenario.expire_time.day,
                                                             scenario.expire_time.hour, scenario.expire_time.minute)
                                        isShowingDisableAlert.toggle()
                                    } else {
                                        sheetScenarioData = scenario
                                    }
                                }
                            }) {
                                buttonContentView(scenario: scenario)
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
        .alert("Not available", isPresented: $isShowingDisableAlert, actions: {
            Button("Cancel", role: .cancel) { }
        }, message: { Text(alertString) })
        .sheet(item: $sheetScenarioData) { scenario in
            NavigationView {
                UseScenarioView(eventAPI: eventAPI, scenario: scenario)
            }
        }
    }
    
    @ViewBuilder
    func buttonContentView(scenario: ScenarioDataModel) -> some View {
        let buttonColor: [String : Color] = [
            "pencil" : Color(red: 88 / 255, green: 174 / 255, blue: 196 / 255),
            "takeoutbag.and.cup.and.straw" : Color.purple,
            "bag" : Color(red: 89 / 255, green: 196 / 255, blue: 189 / 255),
            "gift" : Color(red: 88 / 255, green: 172 / 255, blue: 225 / 255)
        ]
        
        HStack {
            Image(systemName: scenario.used == nil ? scenario.symbolName : "checkmark.circle.fill")
                .font(.callout.bold())
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width * 0.09, height: UIScreen.main.bounds.width * 0.09)
                .background(scenario.used == nil ? buttonColor[scenario.symbolName] ?? .orange : .green)
                .cornerRadius(UIScreen.main.bounds.width * 0.028)
            
            VStack(alignment: .leading) {
                Text(scenario.display_text.zh).foregroundColor(.black)
                Text((scenario.disabled == nil ? (scenario.used == nil ? String(format: "%d:%02d ~ %d:%02d", scenario.available_time.hour, scenario.available_time.minute, scenario.expire_time.hour, scenario.expire_time.minute) : String(format: "Check at %d:%02d", scenario.used!.hour, scenario.used!.minute) ) : (scenario.disabled)!))
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            Spacer()
            if scenario.used == nil && scenario.disabled == nil{
                Image(systemName: "chevron.right").foregroundColor(.gray)
            }
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
