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
    
    @ObservedObject var eventAPI: EventAPIViewModel
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
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
                            .background(.white)
                            .cornerRadius(UIScreen.main.bounds.width * 0.1)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.white.opacity(0))
                    
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
