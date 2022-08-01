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
    
    var body: some View {
        VStack {
            Form {
                AppIconSection()
                
                GeneralSection()
                
                AboutSection()
                
                AdvancedSection()
            }
        }
        .navigationTitle("Setting")
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
    
    @AppStorage("UserInterfaceStyle") var appearance: UIUserInterfaceStyle = .unspecified
    
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
        .onChange(of: appearance) {
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).overrideUserInterfaceStyle = $0
        }
    }
}

fileprivate struct AboutSection: View {
    
    @Environment(\.colorScheme) var colorScheme
    private let CCIPWebsiteURL = URL(string: "https://opass.app")!
    private let CCIPGitHubURL = URL(string: "https://github.com/CCIP-App")!
    private let CCIPPolicyURL = URL(string: "https://opass.app/privacy-policy.html")!
    
    var body: some View {
        Section(header: Text("ABOUT")) {
            VStack(alignment: .leading) {
                Text("Version")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Text(
                    String("\(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!)") +
                    String(" (Build \(Bundle.main.infoDictionary!["CFBundleVersion"]!))")
                )
                .font(.subheadline)
                .foregroundColor(.gray)
            }
            
            Button {
                OpenInAppSafari(forURL: CCIPWebsiteURL, style: colorScheme)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("OfficialWebsite")
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
            
            Button {
                OpenInAppSafari(forURL: CCIPGitHubURL, style: colorScheme)
            } label: {
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
            
            Button {
                OpenInAppSafari(forURL: CCIPPolicyURL, style: colorScheme)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("PrivacyPolicy")
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
    }
}

fileprivate struct AdvancedSection: View {
    var body: some View {
        Section(header: Text("ADVANCED")) {
            NavigationLink(destination: AdvancedOptionView()) {
                Image(systemName: "hammer")
                Text("AdvancedOption")
            }
        }
    }
}

fileprivate struct AdvancedOptionView: View {
    
    private var keyStore = NSUbiquitousKeyValueStore()
    @EnvironmentObject var OPassAPI: OPassAPIViewModel
    
    var body: some View {
        Form {
            Button(action: {
                keyStore.removeObject(forKey: "EventAPI")
                keyStore.synchronize()
            }) {
                Label("ClearCacheData", systemImage: "trash")
            }
        }
        .navigationTitle("AdvancedOption")
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
