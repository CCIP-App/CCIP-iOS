//
//  SettingView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//  2022 OPass.
//

import SwiftUI
import BetterSafariView

struct SettingView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var OPassAPI: OPassAPIViewModel
    @Environment(\.openURL) var openURL
    @State var isShowingSafari = false
    @State var url = URL(string: "https://opass.app")!
    private let CCIPWebsiteURL = URL(string: "https://opass.app")!
    private let CCIPGitHubURL = URL(string: "https://github.com/CCIP-App")!
    private let CCIPPolicyURL = URL(string: "https://opass.app/privacy-policy.html")!
    
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
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Text(
                            String(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String + " (Build ") +
                            String(Bundle.main.infoDictionary!["CFBundleVersion"] as! String + ")")
                        )
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        url = CCIPWebsiteURL
                        isShowingSafari.toggle()
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(LocalizedStringKey("OfficialWebsite"))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text("\(CCIPWebsiteURL)")
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
                        url = CCIPGitHubURL
                        isShowingSafari.toggle()
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("GitHub")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text("\(CCIPGitHubURL)")
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
                        url = CCIPPolicyURL
                        isShowingSafari.toggle()
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(LocalizedStringKey("PrivacyPolicy"))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text("\(CCIPPolicyURL)")
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
            .safariView(isPresented: $isShowingSafari) {
                SafariView(
                    url: url,
                    configuration: SafariView.Configuration(
                        entersReaderIfAvailable: false,
                        barCollapsingEnabled: true
                    )
                )
                .preferredBarAccentColor(.white)
                .preferredControlAccentColor(.accentColor)
                .dismissButtonStyle(.done)
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
                    Text("Clear Cache Data")
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
