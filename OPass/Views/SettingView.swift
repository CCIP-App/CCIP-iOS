//
//  SettingView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//  2022 OPass.
//

import SwiftUI

struct SettingView: View {
    
    @EnvironmentObject var OPassAPI: OPassAPIViewModel
    @Environment(\.openURL) var openURL
    private let CCIPWebsite = "https://opass.app"
    private let CCIPGithub = "https://github.com/CCIP-App"
    private let CCIPPolicy = "https://opass.app/privacy-policy.html"
    
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
                
                Section(header: Text(LocalizedStringKey("ABOUT"))) {
                    VStack(alignment: .leading) {
                        Text(LocalizedStringKey("Version"))
                            .foregroundColor(.black)
                        Text(
                            String(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String + " (Build ") +
                            String(Bundle.main.infoDictionary!["CFBundleVersion"] as! String + ")")
                        )
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        openURL(URL(string: CCIPWebsite)!)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(LocalizedStringKey("OfficialWebsite"))
                                    .foregroundColor(.black)
                                Text(CCIPWebsite)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image("external-link")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                                .frame(width: UIScreen.main.bounds.width * 0.045)
                        }
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
                            
                            Image("external-link")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                                .frame(width: UIScreen.main.bounds.width * 0.045)
                        }
                    }
                    
                    Button(action: {
                        openURL(URL(string: CCIPPolicy)!)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(LocalizedStringKey("PrivacyPolicy"))
                                    .foregroundColor(.black)
                                Text(CCIPPolicy)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image("external-link")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                                .frame(width: UIScreen.main.bounds.width * 0.045)
                        }
                    }

                }
                
                Section(header: Text("DEVELOPER")) {
                    NavigationLink(destination: DeveloperOptionView()) {
                        Image(systemName: "hammer")
                        Text("Developer Option")
                    }
                }
            }
        }
        .navigationTitle(LocalizedStringKey("Setting"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DeveloperOptionView: View {
    
    private var keyStore = NSUbiquitousKeyValueStore()
    @EnvironmentObject var OPassAPI: OPassAPIViewModel
    @State var isDebug = false
    
    var body: some View {
        Form {
            Button(action: {
                keyStore.synchronize()
                keyStore.removeObject(forKey: "EventAPI")
            }) {
                Label {
                    Text("Clear Cach Data (Restart required)")
                } icon: {
                    Image(systemName: "trash")
                }
            }
        }
        .navigationTitle("Developer Option")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
#endif
