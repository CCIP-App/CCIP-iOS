//
//  TicketView.swift
//  OPass
//
//  Created by 張智堯 on 2022/4/1.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct TicketView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        VStack {
            if let token = eventAPI.accessToken {
                Form {
                    Section(header: Text("QRCode")) {
                        HStack {
                            Spacer()
                            Image(uiImage: generateQRCode(from: token))
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width * 0.6, height: UIScreen.main.bounds.width * 0.6)
                            Spacer()
                        }
                    }
                    
                    Section(header: Text("Token")) {
                        Text(token)
                    }
                }
            } else {
                Text("Havn't check in")
            }
        }
        .navigationTitle("Ticket")
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
}

//struct TicketView_Previews: PreviewProvider {
//    static var previews: some View {
//        TicketView()
//    }
//}
