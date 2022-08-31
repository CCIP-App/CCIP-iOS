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
    
    @Environment(\.colorScheme) var colorScheme
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
                    .listRowBackground(Color.transparent)
                
                ForEach(eventAPI.scenario_status?.scenarios.sectionID ?? [], id: \.self) { sectionID in
                    Section(header: Text(sectionID)) {
                        ForEach(eventAPI.scenario_status?.scenarios.sectionData[sectionID] ?? [], id: \.self) { scenario in
                            Button(action: {
                                if scenario.used == nil {
                                    if let errorText = scenario.disabled {
                                        alertString = String(localized: String.LocalizationValue(errorText))
                                        isShowingDisableAlert.toggle()
                                    } else if !DateInRegion().isInRange(date: scenario.available_time,
                                                                        and: scenario.expire_time, orEqual: false,
                                                                        granularity: .second) {
                                        alertString = String(format: String(localized: "OnlyAvailableAtContent"),
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
                                buttonContentView(scenario, sectionID: sectionID)
                            }
                        }
                    }
                }
                .alert("NotAvailable", isPresented: $isShowingDisableAlert, actions: {
                    Button(String(localized: "Cancel"), role: .cancel) { }
                }, message: { Text(alertString) })
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isShowingLogOutAlert.toggle()
                }) { Text(LocalizedStringKey("SignOut")).foregroundColor(.red) }
            }
        }
        .alert("ConfirmSignOut", isPresented: $isShowingLogOutAlert) {
            Button(String(localized: "SignOut"), role: .destructive) {
                eventAPI.signOut()
            }
            Button(String(localized: "Cancel"), role: .cancel) { }
        }
        .sheet(item: $sheetScenarioData) { scenario in
            UseScenarioView(eventAPI: eventAPI, scenario: scenario)
        }
    }
    
    @ViewBuilder
    func buttonContentView(_ scenario: ScenarioDataModel, sectionID: String) -> some View {
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
                Text(scenario.display_text.localized())
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Text(
                    scenario.disabled == nil
                    ? scenario.used == nil
                    ? sectionID.contains("•")
                    ? String(
                        format: "%d:%02d ~ %d:%02d",
                        scenario.available_time.hour,
                        scenario.available_time.minute,
                        scenario.expire_time.hour,
                        scenario.expire_time.minute
                    )
                    : scenario.available_time.month == scenario.expire_time.month && scenario.available_time.day == scenario.expire_time.day
                    ? String(
                        format: "%d/%d • %d:%02d ~ %d:%02d",
                        scenario.available_time.month,
                        scenario.available_time.day,
                        scenario.available_time.hour,
                        scenario.available_time.minute,
                        scenario.expire_time.hour,
                        scenario.expire_time.minute
                    )
                    : String(
                        format: "%d/%d • %d:%02d ~ %d/%d • %d:%02d",
                        scenario.available_time.month,
                        scenario.available_time.day,
                        scenario.available_time.hour,
                        scenario.available_time.minute,
                        scenario.expire_time.month,
                        scenario.expire_time.day,
                        scenario.expire_time.hour,
                        scenario.expire_time.minute
                    )
                    : String(
                        format: String(localized: "CheckAtContent"),
                        scenario.used!.hour,
                        scenario.used!.minute
                    )
                    : String(localized: String.LocalizationValue(scenario.disabled!))
                )
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
            if let logo = eventAPI.logo {
                logo
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color("LogoColor"))
            } else {
                Text(eventAPI.display_name.localized())
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
        ScenarioView(eventAPI: OPassAPIViewModel.mock().currentEventAPI!)
    }
}
#endif
