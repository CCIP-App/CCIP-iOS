//
//  TicketView.swift
//  OPass
//
//  Created by 張智堯 on 2022/4/1.
//  2022 OPass.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import AlertToast
import EFQRCode

struct TicketView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var eventAPI: EventAPIViewModel
    @State var showingTokenCopyToast = false
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
                                    Image(uiImage: QRCode(string: token))
                                        .interpolation(.none)
                                    
                                    /*Image("InAppIcon")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: UIScreen.main.bounds.width * 0.1)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 4)
                                        )*/
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
                        Text(token)
                    }
                    .onLongPressGesture {
                        UIPasteboard.general.string = token
                        showingTokenCopyToast.toggle()
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
        .toast(isPresenting: $showingTokenCopyToast){
            AlertToast(displayMode: .banner(.pop), type: .regular, title: String(localized: "TokenCopied"), style: .style(backgroundColor: Color("SectionBackgroundColor")))
        }
    }
    
    private func QRCode(string: String) -> UIImage {
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
