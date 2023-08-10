//
//  ErrorView.swift
//  OPass
//
//  Created by 張智堯 on 2022/5/1.
//  2023 OPass.
//

import SwiftUI

struct ErrorWithRetryView: View {
    
    var message: LocalizedStringKey? = nil
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color("LogoColor"))
                .frame(width: UIScreen.main.bounds.width * 0.25)
                .padding(.bottom, 8)
            
            Text(message == nil ? "ErrorWithRetryContent" : message!)
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Button(action: action) {
                Text(LocalizedStringKey("TryAgain"))
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(2)
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
            
            Text(LocalizedStringKey("ErrorContent"))
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
    }
}

#if DEBUG
struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorWithRetryView() {}
    }
}
#endif
