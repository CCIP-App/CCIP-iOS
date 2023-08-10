//
//  AppearanceView.swift
//  OPass
//
//  Created by 張智堯 on 2022/8/8.
//  2023 OPass.
//

import SwiftUI

struct AppearanceView: View {
    
    var body: some View {
        Form {
            Section("SCHEDULE") {
                ScheduleOptions()
            }
            Section {
                DarkModePicker()
            }
            Section {
                ResetAllAppearanceButton()
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ScheduleOptions: View {
    
    @AppStorage("DimPastSession") var dimPastSession = true
    @AppStorage("PastSessionOpacity") var pastSessionOpacity: Double = 0.4
    let sampleTimeHour: [Int] = [
        Calendar.current.component(.hour, from: Date.now.advanced(by: -3600)),
        Calendar.current.component(.hour, from: Date.now),
        Calendar.current.component(.hour, from: Date.now.advanced(by: 3600)),
        Calendar.current.component(.hour, from: Date.now.advanced(by: 7200))
    ]
    
    var body: some View {
        List {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack() {
                        Text("OPass Room 1")
                            .font(.caption2)
                            .padding(.vertical, 1)
                            .padding(.horizontal, 8)
                            .foregroundColor(.white)
                            .background(.blue)
                            .cornerRadius(5)
                        
                        Text(String(format: "%d:00 ~ %d:00", sampleTimeHour[0], sampleTimeHour[1]))
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                    Text("PastSession")
                        .lineLimit(2)
                }
                
                .opacity(self.dimPastSession ? self.pastSessionOpacity : 1)
                .padding(.horizontal, 5)
                .padding(10)
                Spacer()
            }
            .background(Color("SectionBackgroundColor"))
            .cornerRadius(8)
            
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack() {
                        Text("OPass Room 2")
                            .font(.caption2)
                            .padding(.vertical, 1)
                            .padding(.horizontal, 8)
                            .foregroundColor(.white)
                            .background(.blue)
                            .cornerRadius(5)
                        
                        Text(String(format: "%d:00 ~ %d:00", sampleTimeHour[2], sampleTimeHour[3]))
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                    Text("FutureSession")
                        .lineLimit(2)
                }
                .padding(.horizontal, 5)
                .padding(10)
                Spacer()
            }
            .background(Color("SectionBackgroundColor"))
            .cornerRadius(8)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 6, trailing: 10))
        
        Toggle("Dim Past Session", isOn: $dimPastSession.animation())
        
        if self.dimPastSession {
            Slider(
                value: $pastSessionOpacity.animation(),
                in: 0.1...0.9,
                onEditingChanged: {_ in},
                minimumValueLabel: Image(systemName: "sun.min"),
                maximumValueLabel: Image(systemName: "sun.min.fill"),
                label: {}
            )
        }
    }
}

private struct DarkModePicker: View {
    
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("UserInterfaceStyle") var userInterfaceStyle: UIUserInterfaceStyle = .unspecified
    private let buttons: [(LocalizedStringKey, UIUserInterfaceStyle)] = [("System", .unspecified), ("On", .dark), ("Off", .light)]
    private let darkModeStatusText: [UIUserInterfaceStyle : LocalizedStringKey] = [.unspecified : "System", .dark : "On", .light : "Off"]
    
    var body: some View {
        NavigationLink {
            Form {
                Section {
                    ForEach(buttons, id: \.1) { (name, interfaceStyle) in
                        Button {
                            self.userInterfaceStyle = interfaceStyle
                            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).overrideUserInterfaceStyle = interfaceStyle
                        } label: {
                            HStack {
                                Text(name)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Spacer()
                                if self.userInterfaceStyle == interfaceStyle {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("DarkMode")
            .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Text("DarkMode")
                Spacer()
                Text(darkModeStatusText[userInterfaceStyle]!)
                    .foregroundColor(.gray)
            }
        }
    }
}

private struct ResetAllAppearanceButton: View {
    
    @AppStorage("DimPastSession") var dimPastSession = true
    @AppStorage("PastSessionOpacity") var pastSessionOpacity: Double = 0.4
    @AppStorage("UserInterfaceStyle") var userInterfaceStyle: UIUserInterfaceStyle = .unspecified
    
    var body: some View {
        Button {
            withAnimation {
                self.dimPastSession = true
                self.pastSessionOpacity = 0.4
            }
            self.userInterfaceStyle = .unspecified
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).overrideUserInterfaceStyle = userInterfaceStyle
        } label: {
            Text("ResetAllAppearance")
                .foregroundColor(.red)
        }
    }
}

#if DEBUG
struct AppearanceView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceView()
    }
}
#endif
