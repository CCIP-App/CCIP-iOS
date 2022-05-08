//
//  UseScenarioView.swift
//  OPass
//
//  Created by 張智堯 on 2022/4/11.
//  2022 OPass.
//

import SwiftUI

struct UseScenarioView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    let scenario: ScenarioDataModel
    @Environment(\.dismiss) var dismiss
    @State var viewStage = 0
    @State var usedTime: TimeInterval = 0
    // 0 -> ConfirmUseScenarioView, 1 -> LoadingView, 2 -> SuccessView, other -> ErrorView
    
    var body: some View {
        VStack {
            switch viewStage {
            case 0:
                ConfirmUseScenarioView()
                    .frame(width: UIScreen.main.bounds.width * 0.85)
            case 1:
                ActivityIndicatorMark_1()
                    .frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.width * 0.25)
            case 2:
                ScuessScenarioView(dismiss: _dismiss, scenario: scenario, usedTime: $usedTime)
            default:
                ErrorView()
            }
        }
        .navigationTitle(LocalizeIn(zh: scenario.display_text.zh, en: scenario.display_text.en))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(LocalizedStringKey("Close")) {
                    dismiss()
                }
            }
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
                Text(LocalizeIn(zh: scenario.display_text.zh, en: scenario.display_text.en))
                    .font(.largeTitle.bold())
                
                Text(LocalizedStringKey("ConfirmUseScenarioMessage"))
                    .multilineTextAlignment(.center)
            }
            
            Group {
                Spacer()
                Spacer()
                Spacer()
            }
            
            Button(action: {
                viewStage = 1
                Task {
                    if await eventAPI.useScenario(scenario: scenario.id) {
                        usedTime = Date().timeIntervalSince1970
                        viewStage = 2
                    } else { viewStage = 3 }
                }
            }) {
                Text(LocalizedStringKey("ConfirmUse"))
                    .foregroundColor(.white)
                    .padding(.vertical, 11)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(10)
            }

            Button(action: { dismiss() }) {
                Text(LocalizedStringKey("Cancel"))
                    .foregroundColor(.blue)
                    .padding(.vertical, 10)
            }
        }
    }
}

fileprivate struct ScuessScenarioView: View {
    
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
                    Text(
                        LocalizeIn(zh: scenario.display_text.zh, en: scenario.display_text.en) +
                        " " + String(localized: "Complete")
                    )
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

fileprivate struct TimerView: View {
    
    let scenario: ScenarioDataModel
    let countTime: Double
    let symbolName: String
    @Environment(\.dismiss) var dismiss
    
    @State var time: Double = 0
    let timer = Timer.publish(every: 0.03, tolerance: 0.05, on: .main, in: .common).autoconnect()
    @Binding var usedTime: TimeInterval
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(String(format: "%d:%02d.%02d", Int(time)/60, Int(time)%100, Int(time*100)%100))
                        .font(.system(size: 70, weight: .light)) //TODO: Dynamic size
                }
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.horizontal)
            
            if let diet = scenario.attr.diet {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Diet")
                            .foregroundColor(.white.opacity(0.5))
                        Text(diet)
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
                            .foregroundColor(Color(red: 77/255, green: 148/255, blue: 247/255))
                    }
                }
                    .frame(maxWidth: .infinity)
            }
            .offset(x: 0, y: 30)
        })
        .background(Color.blue)
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
}
