//
//  LandingView.swift
//  OPass
//
//  Created by 張智堯 on 2022/4/29.
//

import SwiftUI

struct LandingView: View {
    
    @Binding var isShowingEventList: Bool
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("OPass provides the newest event information for you.")
                .font(.title)
            
            Spacer()
            
            Spacer()
            
            Button(action: { isShowingEventList.toggle() }) {
                Text("Get Started")
                    .foregroundColor(.white)
                    .font(.title2)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(.blue)
                    .cornerRadius(15)
            }
            
            VStack {
                Text("By started you accept our")
                    .padding(.top, 5)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.7))
                
                Button(action: {
                    openURL(URL(string: "https://opass.app/privacy-policy.html")!)
                }, label: {
                    Text("Privacy Policy")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black.opacity(0.9))
                        .underline()
                })
            }
            .padding(.bottom)
        }
        .frame(width: UIScreen.main.bounds.width * 0.88)
    }
}

#if DEBUG
struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LandingView(isShowingEventList: .constant(false))
                .navigationTitle("OPass")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        SFButton(systemName: "person.crop.rectangle.stack") {}
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        SFButton(systemName: "gearshape") {}
                    }
                }
        }
    }
}
#endif
