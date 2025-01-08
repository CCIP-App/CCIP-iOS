//
//  ScenarioView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/5.
//  2025 OPass.
//

import SwiftUI
import SwiftDate

struct ScenarioView: View {
    
    // MARK: - Variables
    @EnvironmentObject var EventStore: EventStore
    @State private var disableAlertString = ""
    @State private var isDisableAlertPresented = false
    @State private var isLogOutAlertPresented = false
    @State private var sheetScenarioDataItem: Scenario?
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Views
    var body: some View {
        VStack {
            Form {
                FastpassLogoView()
                    .frame(height: UIScreen.main.bounds.width * 0.4)
                    .listRowBackground(Color.clear)
                
                ForEach(EventStore.attendee?.scenarios.keys ?? [], id: \.self) { sectionID in
                    Section(header: Text(sectionID)) {
                        ForEach(EventStore.attendee?.scenarios[sectionID] ?? []) { scenario in
                            Button {
                                if scenario.used == nil || Date().timeIntervalSince1970 < (scenario.used?.timeIntervalSince1970 ?? 0) + Double(scenario.countdown) {
                                    if let errorText = scenario.disabled {
                                        disableAlertString = String(localized: String.LocalizationValue(errorText))
                                        isDisableAlertPresented.toggle()
                                    } else if !DateInRegion().isInRange(date: scenario.available,
                                                                        and: scenario.expire, orEqual: false,
                                                                        granularity: .second) {
                                        disableAlertString = String(
                                            format: String(localized: "OnlyAvailableAtContent"),
                                            scenario.available.year, scenario.available.month,
                                            scenario.available.day, scenario.available.hour,
                                            scenario.available.minute, scenario.expire.year,
                                            scenario.expire.month, scenario.expire.day,
                                            scenario.expire.hour, scenario.expire.minute
                                        )
                                        isDisableAlertPresented.toggle()
                                    } else { sheetScenarioDataItem = scenario }
                                }
                            } label: { buttonContentView(scenario, sectionID: sectionID) }
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { isLogOutAlertPresented.toggle() } label: {
                    Text("SignOut").foregroundColor(.red)
                }
            }
        }
        .alert("NotAvailable", isPresented: $isDisableAlertPresented, actions: {
            Button(String(localized: "Cancel"), role: .cancel) { }
        }, message: { Text(disableAlertString) })
        .alert("ConfirmSignOut", isPresented: $isLogOutAlertPresented) {
            Button(String(localized: "SignOut"), role: .destructive) {
                EventStore.signOut()
            }
            Button(String(localized: "Cancel"), role: .cancel) { }
        }
        .sheet(item: $sheetScenarioDataItem) { scenario in
            UseScenarioView(
                scenario: scenario,
                used: Date().timeIntervalSince1970 < (scenario.used?.timeIntervalSince1970 ?? 0) + Double(scenario.countdown))
        }
    }
    
    @ViewBuilder
    func buttonContentView(_ scenario: Scenario, sectionID: String) -> some View {
        let buttonColor: [String : Color] = [
            "pencil" : Color(red: 88 / 255, green: 174 / 255, blue: 196 / 255),
            "takeoutbag.and.cup.and.straw" : Color.purple,
            "bag" : Color(red: 89 / 255, green: 196 / 255, blue: 189 / 255),
            "gift" : Color(red: 88 / 255, green: 172 / 255, blue: 225 / 255)
        ]
        
        HStack {
            Image(systemName: scenario.used == nil ? scenario.symbol : "checkmark.circle.fill")
                .font(.callout.bold())
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width * 0.09, height: UIScreen.main.bounds.width * 0.09)
                .background(scenario.used == nil ? buttonColor[scenario.symbol] ?? .orange : .green)
                .cornerRadius(UIScreen.main.bounds.width * 0.028)
            
            VStack(alignment: .leading) {
                Text(scenario.title.localized())
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Text(
                    scenario.disabled == nil
                    ? scenario.used == nil
                    ? sectionID.contains("•")
                    ? String(
                        format: "%d:%02d ~ %d:%02d",
                        scenario.available.hour,
                        scenario.available.minute,
                        scenario.expire.hour,
                        scenario.expire.minute
                    )
                    : scenario.available.month == scenario.expire.month && scenario.available.day == scenario.expire.day
                    ? String(
                        format: "%d/%d • %d:%02d ~ %d:%02d",
                        scenario.available.month,
                        scenario.available.day,
                        scenario.available.hour,
                        scenario.available.minute,
                        scenario.expire.hour,
                        scenario.expire.minute
                    )
                    : String(
                        format: "%d/%d • %d:%02d ~ %d/%d • %d:%02d",
                        scenario.available.month,
                        scenario.available.day,
                        scenario.available.hour,
                        scenario.available.minute,
                        scenario.expire.month,
                        scenario.expire.day,
                        scenario.expire.hour,
                        scenario.expire.minute
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
    
    @EnvironmentObject var EventStore: EventStore
    
    var body: some View {
        HStack {
            Spacer()
            if let logo = EventStore.logo {
                logo
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.logo)
            } else {
                Text(EventStore.config.title.localized())
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.logo)
            }
            Spacer()
        }
    }
}

#if DEBUG
struct ScenarioView_Previews: PreviewProvider {
    static var previews: some View {
        ScenarioView().environmentObject(OPassStore.mock().event!)
    }
}
#endif
