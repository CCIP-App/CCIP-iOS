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
    @State var viewStage = 0 // 0 -> ConfirmUseScenarioView, 1 -> LoadingView, 2 -> SuccessView, other -> ErrorView
    
    var body: some View {
        VStack {
            switch viewStage {
            case 0:
                ConfirmUseScenarioView()
            case 1:
                ActivityIndicatorMark_1()
                    .frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.width * 0.25)
            case 2:
                Text("Scuess") //TODO: Handle Scuess View
            default:
                VStack {
                    Text("Error") //TODO: Handle Error Message
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.85)
        .navigationTitle(scenario.display_text.en)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
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
                Text(scenario.display_text.en)
                    .font(.largeTitle.bold())
                
                Text("This item can only be used once, please follow the instructions of the staff to use.")
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
                        viewStage = 2
                    } else {
                        viewStage = 3
                    }
                }
            }) {
                Text("Confirm Use")
                    .foregroundColor(.white)
                    .padding(.vertical, 11)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(10)
            }

            Button(action: { dismiss() }) {
                Text("Cancel Use")
                    .foregroundColor(.blue)
                    .padding(.vertical, 10)
            }
        }
    }
}

//struct UseScenarioView_Previews: PreviewProvider {
//    static var previews: some View {
//        UseScenarioView()
//    }
//}
