//
//  SettingView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//  2022 OPass.
//

import SwiftUI

struct SettingView: View {
    
    @Environment(\.openURL) var openURL
    @State var isDebug = false
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
                
                Section {
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
                                Text("Official Website")
                                    .foregroundColor(.black)
                                Text(CCIPWebsite)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square.fill")
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
                            
                            Image(systemName: "arrow.up.right.square.fill")
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
                            
                            Image(systemName: "arrow.up.right.square.fill")
                        }
                    }

                }
                
                Section {
                    NavigationLink(destination: EmptyView()) {
                        Text(LocalizedStringKey("DeveloperOption"))
                    }
                    
                    Toggle(LocalizedStringKey("DebugFuction"), isOn: $isDebug)
                }
            }
        }
        .navigationTitle(LocalizedStringKey("Setting"))
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
