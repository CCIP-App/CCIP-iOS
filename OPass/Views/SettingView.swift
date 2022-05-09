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
    
    @EnvironmentObject var OPassAPI: OPassAPIViewModel
    @Environment(\.openURL) var openURL
    @State var isShowCCIPWebsite = false
    @State var isShowCCIPGitHub = false
    @State var isShowCCIPPolicy = false
    private let CCIPWebsite = "https://opass.app"
    private let CCIPGitHub = "https://github.com/CCIP-App"
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
                        isShowCCIPWebsite.toggle()
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
                    .safariView(isPresented: $isShowCCIPWebsite) {
                        SafariView(
                            url: URL(string: CCIPWebsite)!,
                            configuration: SafariView.Configuration(
                                entersReaderIfAvailable: false,
                                barCollapsingEnabled: true
                            )
                        )
                        .preferredBarAccentColor(.white)
                        .preferredControlAccentColor(.accentColor)
                        .dismissButtonStyle(.cancel)
                    }
                    
                    Button(action: {
                        isShowCCIPGitHub.toggle()
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("GitHub")
                                    .foregroundColor(.black)
                                Text(CCIPGitHub)
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
                    .safariView(isPresented: $isShowCCIPGitHub) {
                        SafariView(
                            url: URL(string: CCIPGitHub)!,
                            configuration: SafariView.Configuration(
                                entersReaderIfAvailable: false,
                                barCollapsingEnabled: true
                            )
                        )
                        .preferredBarAccentColor(.white)
                        .preferredControlAccentColor(.accentColor)
                        .dismissButtonStyle(.cancel)
                    }
                    
                    Button(action: {
                        isShowCCIPPolicy.toggle()
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
                    .safariView(isPresented: $isShowCCIPPolicy) {
                        SafariView(
                            url: URL(string: CCIPPolicy)!,
                            configuration: SafariView.Configuration(
                                entersReaderIfAvailable: false,
                                barCollapsingEnabled: true
                            )
                        )
                        .preferredBarAccentColor(.white)
                        .preferredControlAccentColor(.accentColor)
                        .dismissButtonStyle(.cancel)
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
