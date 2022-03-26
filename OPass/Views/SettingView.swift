//
//  SettingView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//

import SwiftUI

struct SettingView: View {
    
    @Environment(\.openURL) var openURL
    @State var isDebug = false
    private let CCIPGithub = "https://github.com/CCIP-App"
    private let policy = "https://opass.app/privacy-policy.html"
    
    var body: some View {
        VStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        
                        VStack {
                            Image("InAppIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.width * 0.28)
                                .clipShape(Circle())
                            
                            Text("OPass")
                        }
                        .padding(5)
                        
                        Spacer()
                    }
                }
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Version")
                            .foregroundColor(.black)
                        Text(
                            String(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String + " (Build ") +
                            String(Bundle.main.infoDictionary!["CFBundleVersion"] as! String + ")")
                        )
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        openURL(URL(string: CCIPGithub)!)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("GitHub")
                                    .foregroundColor(.black)
                                Text(CCIPGithub)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square.fill")
                        }
                    }
                    
                    Button(action: {
                        openURL(URL(string: policy)!)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Privacy Policy")
                                    .foregroundColor(.black)
                                Text(policy)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square.fill")
                        }
                    }

                }
                
                Section {
                    NavigationLink(destination: EmptyView()) {
                        Text("Developer Option")
                    }
                    
                    Toggle("Debug Fuction", isOn: $isDebug)
                }
            }
        }
        .navigationTitle("Setting")
        .navigationBarTitleDisplayMode(.inline)
        
        /*
        //Only for API Testing
        VStack {
            if let data = eventAPI.eventLogo, let uiimage = UIImage(data: data) {
                Image(uiImage: uiimage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.78, height: UIScreen.main.bounds.width * 0.4)
                    .background(Color.purple)
            }
            
            Text(eventAPI.eventSettings?.event_id ?? "No Current Event Data")
            
            ScrollView {
                if let data = eventAPI.eventSettings {
                    ForEach(data.features, id: \.self) { feature in
                        Text(feature.display_text.zh)
                    }
                }
            }
        }*/
    }
}

#if DEBUG
struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
#endif
