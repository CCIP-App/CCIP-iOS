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
                    .listRowBackground(Color.transparent)
                    
                    Section(header: Text("Token")) {
                        Text(token)
                    }
                    
                    HStack(alignment: .center) {
                        Spacer()
                        Text("Please keep your ticket as a secret. Do not share it with anyone else but the staff or event booths.")
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
