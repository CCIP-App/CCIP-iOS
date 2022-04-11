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
    @State var isShowingLoadingView = false
    
    var body: some View {
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
                Text(scenario.display_text.zh)
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
                isShowingLoadingView.toggle()
            }) {
                Text("Confirm Redeem")
                    .foregroundColor(.white)
                    .padding(.vertical, 11)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(10)
            }

            Button(action: { dismiss() }) {
                Text("Cancel Redeem")
                    .foregroundColor(.blue)
                    .padding(.vertical, 10)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.85)
        .navigationTitle(scenario.display_text.zh)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

//struct UseScenarioView_Previews: PreviewProvider {
//    static var previews: some View {
//        UseScenarioView()
//    }
//}
