//
//  TicketView.swift
//  OPass
//
//  Created by 張智堯 on 2022/4/1.
//  2022 OPass.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct TicketView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var eventAPI: EventAPIViewModel
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
                                    Image(uiImage: generateQRCode(from: token))
                                        .interpolation(.none)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: UIScreen.main.bounds.width * 0.6)
                                    
                                    Image("InAppIcon")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: UIScreen.main.bounds.width * 0.1)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 4)
                                        )
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
    }
    
    private func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    private func QrCode(_ uiImage: UIImage, colorScheme: ColorScheme) -> UIImage {
        if colorScheme == .dark {
            return uiImage.invertColor()?.transparentBackground() ?? UIImage()
        }
        return uiImage
    }
}

extension UIImage {

    func transparentBackground() -> UIImage? {
        let context = CIContext(options: nil)
        let filter = CIFilter(name: "CIMaskToAlpha")
        filter?.setDefaults()
        filter?.setValue(self.ciImage, forKey: kCIInputImageKey)
        if let output = filter?.outputImage,
           let imageRef = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: imageRef)
        }
        return nil
    }

    func invertColor() -> UIImage? {
        let filter = CIFilter(name: "CIColorInvert")
        filter?.setDefaults()
        filter?.setValue(self.ciImage, forKey: kCIInputImageKey)
        if let output = filter?.outputImage {
            return UIImage(ciImage: output)
        }
        return nil
    }

}
