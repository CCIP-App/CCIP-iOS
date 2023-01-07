//
//  UseScenarioView.swift
//  OPass
//
//  Created by 張智堯 on 2022/4/11.
//  2023 OPass.
//

import SwiftUI

struct UseScenarioView: View {
    
    let scenario: ScenarioDataModel
    @EnvironmentObject var EventService: EventService
    @State private var viewStage = 0
    @State private var isHttp403AlertPresented = false
    @State private var usedTime: TimeInterval = 0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                switch viewStage {
                case 0: ConfirmUseScenarioView()
                case 1: ActivityIndicatorMark_1()
                        .frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.width * 0.25)
                case 2: ScuessScenarioView(dismiss: _dismiss, scenario: scenario, usedTime: $usedTime)
                default: ErrorView()
                }
            }
            .navigationTitle(scenario.display_text.localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("Close")) {
                        dismiss()
                    }
                }
            }
            .http403Alert(isPresented: $isHttp403AlertPresented)
        }
    }
    
    @ViewBuilder
    func ConfirmUseScenarioView() -> some View {
        VStack {
            Spacer()
            
            VStack(spacing: 10) {
                Image(systemName: scenario.symbolName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.2, height: UIScreen.main.bounds.width * 0.2)
                    .background(.blue)
                    .cornerRadius(UIScreen.main.bounds.width * 0.05)
                Text(scenario.display_text.localized())
                    .font(.largeTitle.bold())
                
                Text("ConfirmUseScenarioMessage")
                    .multilineTextAlignment(.center)
            }
            
            Group {
                Spacer()
                Spacer()
                Spacer()
            }
            
            Button {
                self.viewStage = 1
                Task {
                    do {
                        if try await EventService.useScenario(scenario: scenario.id) {
                            self.usedTime = Date().timeIntervalSince1970
                            self.viewStage = 2
                        } else { self.viewStage = 3 }
                    } catch APIRepo.LoadError.http403Forbidden {
                        self.isHttp403AlertPresented = true
                    } catch { self.viewStage = 3 }
                }
            } label: {
                Text("ConfirmUse")
                    .foregroundColor(.white)
                    .padding(.vertical, 11)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(10)
            }
            
            Button { dismiss() } label: {
                Text("Cancel")
                    .foregroundColor(.blue)
                    .padding(.vertical, 10)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.85)
    }
}

private struct ScuessScenarioView: View {
    
    @Environment(\.dismiss) var dismiss
    let scenario: ScenarioDataModel
    @State var time = 0
    @Binding var usedTime: TimeInterval
    
    var body: some View {
        VStack {
            if scenario.countdown != 0 {
                TimerView(scenario: scenario, countTime: Double(scenario.countdown), symbolName: scenario.symbolName, dismiss: _dismiss, usedTime: $usedTime)
                    .padding()
            } else {
                VStack {
                    Spacer()
                    Image(systemName: "checkmark.square.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.2)
                        .foregroundColor(.green)
                    Text(scenario.display_text.localized() + " " + String(localized: "Complete"))
                        .font(.title.bold())
                    Group{
                        Spacer()
                        Spacer()
                    }
                }
            }
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Text(LocalizedStringKey("Complete"))
                    .foregroundColor(.white)
                    .padding(.vertical, 11)
                    .frame(width: UIScreen.main.bounds.width * 0.85)
                    .background(.blue)
                    .cornerRadius(10)
            }
            .padding(.bottom)
        }
    }
}

private struct TimerView: View {
    
    let scenario: ScenarioDataModel
    let countTime: Double
    let symbolName: String
    @Environment(\.dismiss) var dismiss
    
    @State var time: Double = 0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @Binding var usedTime: TimeInterval
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(String(format: "%d:%02d", Int(time)/60, Int(time)%100))
                        .font(.system(size: 70, weight: .light)) //TODO: Dynamic size
                }
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.horizontal)
            
            ForEach(scenario.attr.keys.sorted(), id: \.self) { key in
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(key.capitalizingFirstLetter())
                            .foregroundColor(.white.opacity(0.5))
                        Text(scenario.attr[key]?.capitalizingFirstLetter() ?? "")
                            .foregroundColor(.white)
                            .fontWeight(.light)
                            .font(.largeTitle)
                            .multilineTextAlignment(.leading)
                            .offset(x: 0, y: -10)
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.width * 0.5)
        .background(content: {
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    Spacer()
                    if symbolName != "" {
                        Image(systemName: symbolName)
                            .font(.system(size: UIScreen.main.bounds.width*0.18, weight: .bold, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.2))
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .offset(x: 0, y: 30)
        })
        .background(BackgroundColor(diet: scenario.attr["diet"]))
        .cornerRadius(10)
        .onReceive(timer) { _ in
            let tmpTime = countTime - (Date().timeIntervalSince1970 - usedTime)
            if tmpTime <= 0 {
                dismiss()
            } else {
                time = tmpTime
            }
        }
    }
    
    private func BackgroundColor(diet: String?) -> Color {
        switch diet {
        case "meat": return Color(red: 1, green: 160/255, blue: 0)
        case "vegetarian": return Color(red: 41/255, green: 138/255, blue: 8/255)
        default: return Color.blue
        }
    }
}
