//
//  ErrorView.swift
//  OPass
//
//  Created by 張智堯 on 2022/5/1.
//  2022 OPass.
//

import SwiftUI

struct ErrorWithRetryView: View {
    
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color("LogoColor"))
                .frame(width: UIScreen.main.bounds.width * 0.25)
                .padding(.bottom, 8)
            
            //Text(LocalizedStringKey("OhNo"))
            //    .font(.largeTitle)
            //    .foregroundColor(.black)
            //    .padding(.bottom, 3)
            Text(LocalizedStringKey("ErrorWithRetryContent"))
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.bottom, 2)
            
            Button(action: action) {
                Text(LocalizedStringKey("TryAgain"))
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
    }
}

struct ErrorView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color("LogoColor"))
                .frame(width: UIScreen.main.bounds.width * 0.25)
                .padding(.bottom, 8)
            
            //Text(LocalizedStringKey("OhNo"))
            //    .font(.largeTitle)
            //    .foregroundColor(.black)
            //    .padding(.bottom, 3)
            Text(LocalizedStringKey("ErrorContent"))
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorWithRetryView() {}
    }
}
