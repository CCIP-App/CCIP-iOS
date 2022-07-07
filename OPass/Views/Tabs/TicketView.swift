//
//  TicketView.swift
//  OPass
//
//  Created by 張智堯 on 2022/4/1.
//  2022 OPass.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import EFQRCode

struct TicketView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var eventAPI: EventAPIViewModel
    @State var showingToken = false
    @State var isShowingLogOutAlert = false
    @State var qrCodeUIImage = UIImage()
    let display_text: DisplayTextModel
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    init(eventAPI: EventAPIViewModel) {
        self.eventAPI = eventAPI
        self.display_text = eventAPI.eventSettings.feature(ofType: .ticket).display_text
    }
    
    var body: some View {
        VStack {
            if let token = eventAPI.accessToken {
                Form {
                    Section() {
                        HStack {
                            Spacer()
                            VStack(spacing: 0) {
                                ZStack {
                                    Image(uiImage: qrCodeUIImage)
                                        .interpolation(.none)
                                        .onAppear {
                                            qrCodeUIImage = renderQRCode(string: token)
                                        }
                                }
                                
                                VStack {
                                    if let id = eventAPI.eventScenarioStatus?.user_id {
                                        Text("@\(id)")
                                            .font(.system(.title, design: .rounded))
                                            .fontWeight(.medium)
                                    }
                                }
                                .padding(.vertical, UIScreen.main.bounds.width * 0.04)
                            }
                            .padding([.leading, .trailing, .top], UIScreen.main.bounds.width * 0.08)
                            .background(Color("SectionBackgroundColor"))
                            .cornerRadius(UIScreen.main.bounds.width * 0.1)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.transparent)
                    
                    Section(header: Text(LocalizedStringKey("Token"))) {
                        HStack {
                            showingToken
                            ? Text(token)
                            : Text(String(repeating: "•", count: token.count))
                                .font(.title3)
                        }
                    }
                    .onTapGesture {
                        showingToken.toggle()
                    }
                    .contextMenu {
                        Button {
                            UIPasteboard.general.string = token
                        } label: {
                            Label(String(localized: "Copy Token"), systemImage: "square.on.square")
                        }
                    }
                    
                    HStack(alignment: .center) {
                        Spacer()
                        Text(LocalizedStringKey("TicketWarningContent"))
                            .foregroundColor(.gray)
                            .font(.footnote)
                        Spacer()
                    }
                        .listRowBackground(Color.transparent)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            } else {
                RedeemTokenView(eventAPI: eventAPI)
            }
        }
        .navigationTitle(LocalizeIn(zh: display_text.zh, en: display_text.en))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if eventAPI.accessToken != nil {
                    Button(action: {
                        isShowingLogOutAlert.toggle()
                    }) { Text(LocalizedStringKey("SignOut")).foregroundColor(.red) }
                }
            }
        }
        .alert(LocalizedStringKey("ConfirmSignOut"), isPresented: $isShowingLogOutAlert) {
            Button(String(localized: "SignOut"), role: .destructive) {
                eventAPI.signOut()
            }
            Button(String(localized: "Cancel"), role: .cancel) { }
        }
    }
    
    private func renderQRCode(string: String) -> UIImage {
        let generator = EFQRCodeGenerator(content: string, encoding: .utf8, size: EFIntSize())
        
        generator.withInputCorrectionLevel(.h)
        generator.withColors(backgroundColor: UIColor(Color("SectionBackgroundColor")).cgColor, foregroundColor: UIColor(colorScheme == .dark ? Color.white : Color.black).cgColor)
        if let maxMagnification = generator
            .maxMagnification(lessThanOrEqualTo: UIScreen.main.bounds.width * 0.6) {
            generator.magnification = EFIntSize(
                width: maxMagnification,
                height: maxMagnification
            )
        }
        
        if let cgImage = generator.generate() {
            return UIImage(cgImage: cgImage)
        }
        return UIImage()
    }
}
