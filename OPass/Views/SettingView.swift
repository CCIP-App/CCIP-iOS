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
    
    var body: some View {
        VStack {
            Form {
                AppIconSection()
                
                GeneralSection()
                
                AboutSection()
                
                DeveloperSection()
            }
        }
        .navigationTitle(LocalizedStringKey("Setting"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate struct AppIconSection: View {
    var body: some View {
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
    }
}

fileprivate struct GeneralSection: View {
    
    @AppStorage("appearance") var appearance: UIUserInterfaceStyle = .unspecified
    
    var body: some View {
        Section(header: Text("GENERAL")) {
            Picker(selection: $appearance) {
                Text("System").tag(UIUserInterfaceStyle.unspecified)
                Text("Light").tag(UIUserInterfaceStyle.light)
                Text("Dark").tag(UIUserInterfaceStyle.dark)
            } label: {
                Label { Text("Appearance") } icon: {
                    Image(systemName: "circle.lefthalf.filled")
                        .padding(5)
                        .foregroundColor(.white)
                        .background(Color(red: 89/255, green: 169/255, blue: 214/255))
                        .cornerRadius(7)
                }
            }
        }
    }
}

fileprivate struct AboutSection: View {
    
    @Environment(\.colorScheme) var colorScheme
    private let CCIPWebsiteURL = URL(string: "https://opass.app")!
    private let CCIPGitHubURL = URL(string: "https://github.com/CCIP-App")!
    private let CCIPPolicyURL = URL(string: "https://opass.app/privacy-policy.html")!
    
    @State var isShowingSafari = false
    
    var body: some View {
        var url = URL(string: "https://opass.app")!
        Section(header: Text(LocalizedStringKey("ABOUT"))) {
            VStack(alignment: .leading) {
                Text(LocalizedStringKey("Version"))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Text(
                    String("\(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!)") +
                    String(" (Build \(Bundle.main.infoDictionary!["CFBundleVersion"]!))")
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
                        Text(CCIPWebsiteURL.absoluteString)
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
                        Text(CCIPGitHubURL.absoluteString)
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
                        Text(CCIPPolicyURL.absoluteString)
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
        .safariView(isPresented: $isShowingSafari) {
            SafariView(
                url: url,
                configuration: .init(
                    entersReaderIfAvailable: false,
                    barCollapsingEnabled: true
                )
            )
            .preferredBarAccentColor(colorScheme == .dark ? Color(red: 28/255, green: 28/255, blue: 30/255) : .white)
        }
    }
}

fileprivate struct DeveloperSection: View {
    var body: some View {
        Section(header: Text("DEVELOPER")) {
            NavigationLink(destination: DeveloperOptionView()) {
                Image(systemName: "hammer")
                Text("Developer Option")
            }
        }
    }
}

fileprivate struct DeveloperOptionView: View {
    
    private var keyStore = NSUbiquitousKeyValueStore()
    @EnvironmentObject var OPassAPI: OPassAPIViewModel
    @State var isDebug = false
    
    var body: some View {
        Form {
            Button(action: {
                keyStore.removeObject(forKey: "EventAPI")
                keyStore.synchronize()
            }) {
                Label("Clear Cache Data", systemImage: "trash")
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
