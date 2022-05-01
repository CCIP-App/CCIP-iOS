//
//  ErrorView.swift
//  OPass
//
//  Created by 張智堯 on 2022/5/1.
//

import SwiftUI

struct ErrorView: View {
    
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color("LogoColor"))
                .frame(width: UIScreen.main.bounds.width * 0.25)
                .padding(.bottom, 8)
            
            Text("Oh no!")
                .font(.largeTitle)
                .foregroundColor(.black)
                .padding(.bottom, 3)
            Text("Something went wrong, but don't feel fret.\nLet's give it another shot.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.bottom, 2)
            
            Button(action: action) {
                Text("Try Again")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView() {}
    }
}
