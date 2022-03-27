//
//  RedeemTokenView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/5.
//

import SwiftUI
import SlideOverCard
import CodeScanner

struct RedeemTokenView: View {
    
    @State var token: String = ""
    @ObservedObject var eventAPI: EventAPIViewModel
    
    @State var isShowingSOC = false
    @State var SOCViewSwitch = 0 // 0 -> Camera, 1 -> Manually
    
    var body: some View {
        VStack {
            Form {
                HStack {
                    Spacer()
                    if let eventLogoData = eventAPI.eventLogo, let eventLogoUIImage = UIImage(data: eventLogoData) {
                        Image(uiImage: eventLogoUIImage)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color("LogoColor"))
                    } else {
                        Text(eventAPI.display_name.en)
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(Color("LogoColor"))
                    }
                    Spacer()
                }
                .frame(height: UIScreen.main.bounds.width * 0.4)
                .listRowBackground(Color.white.opacity(0))
                
                Section {
                    Button(action: {
                        SOCViewSwitch = 0
                        isShowingSOC.toggle()
                    }) {
                        HStack {
                            Image(systemName: "camera")
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(9)
                            Text("Scan token with camera").foregroundColor(Color.black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        
                    }) {
                        HStack {
                            Image(systemName: "photo")
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .cornerRadius(9)
                            Text("Select a picture to scan token").foregroundColor(Color.black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        SOCViewSwitch = 1
                        isShowingSOC.toggle()
                    }) {
                        HStack {
                            Image(systemName: "keyboard")
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 10)
                                .background(Color.purple)
                                .cornerRadius(9)
                            Text("Enter token manually").foregroundColor(Color.black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                }
            }
            
            //Task {
            //    await eventAPI.redeemToken(token: token)
            //}
        }
        .slideOverCard(isPresented: $isShowingSOC) {
            VStack {
                switch SOCViewSwitch {
                case 0: // 0 -> Camera
                    Text("Fast Pass").font(Font.largeTitle.weight(.bold))
                    Text("Scan token with camera")
                    
                    //TODO: Handle Camera not permit
                    CodeScannerView(codeTypes: [.qr], scanMode: .once, showViewfinder: false, shouldVibrateOnSuccess: true, completion: handleScan)
                        .frame(height: UIScreen.main.bounds.height * 0.25)
                        .cornerRadius(20)
                    
                    VStack(alignment: .leading) {
                        Text("Scan to get token").bold()
                        Text("Please look for the QRCode provided by the email and place it in the viewfinder")
                            .foregroundColor(Color.gray)
                    }
                default: // 1 -> Manually
                    Text("Fast Pass").font(Font.largeTitle.weight(.bold))
                    Text("Enter token manually")
                    
                    TextField("Token", text: $token)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.yellow, lineWidth: 2)
                        )
                    
                    VStack(alignment: .leading) {
                        Text("Please look for the Token provided by the email and enter it in the field above")
                            .foregroundColor(Color.gray)
                            .font(.caption)
                    }
                    
                    Button(action: {
                        isShowingSOC.toggle()
                    }) {
                        HStack {
                            Spacer()
                            Text("Continue")
                                .padding(.vertical, 20)
                                .foregroundColor(Color.white)
                            Spacer()
                        }.background(Color("LogoColor")).cornerRadius(12)
                    }
                    
                }
            }
        }
    }
    
    //TODO: Handle token
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingSOC = false
        
        switch result {
        case .success(let result):
            print(result.string)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }

}

#if DEBUG
struct RedeemTokenView_Previews: PreviewProvider {
    static var previews: some View {
        RedeemTokenView(eventAPI: OPassAPIViewModel.mock().eventList[5])
    }
}
#endif
