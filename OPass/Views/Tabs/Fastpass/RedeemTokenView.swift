//
//  RedeemTokenView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/5.
//  2022 OPass.
//

import SwiftUI
import UIKit
import SlideOverCard
import CodeScanner
import AVFoundation

struct RedeemTokenView: View {
    
    enum Field: Hashable {
        case ManuallyToken
    }
    
    @State var token: String = ""
    @ObservedObject var eventAPI: EventAPIViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var isShowingCameraSOC = false
    @State var isShowingImagePicker = false
    @State var isShowingNoQRCodeAlert = false
    @State var isShowingManuallySOC = false
    @State var isShowingTokenErrorAlert = false
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack {
            Form {
                FastpassLogoView(eventAPI: eventAPI)
                .frame(height: UIScreen.main.bounds.width * 0.4)
                .listRowBackground(Color.white.opacity(0))
                
                Section {
                    Button(action: {
                        isShowingCameraSOC.toggle()
                    }) {
                        HStack {
                            Image(systemName: "camera")
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(9)
                            Text(LocalizedStringKey("ScanQRCodeWithCamera")).foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                    .alert(LocalizedStringKey("InvaildToken"), isPresented: $isShowingTokenErrorAlert) {
                        Button("OK", role: .cancel) {
                            token = ""
                        }
                    }
                    
                    Button(action: {
                        isShowingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .cornerRadius(9)
                            Text(LocalizedStringKey("SelectAPictureToScanQRCode")).foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                    .alert(LocalizedStringKey("NoQRCodeFoundInPicture"), isPresented: $isShowingNoQRCodeAlert) {
                        Button("OK", role: .cancel) {
                            isShowingNoQRCodeAlert = false
                        }
                    }
                    
                    Button(action: {
                        isShowingManuallySOC.toggle()
                    }) {
                        HStack {
                            Image(systemName: "keyboard")
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 10)
                                .background(Color.purple)
                                .cornerRadius(9)
                            Text(LocalizedStringKey("EnterTokenManually")).foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .slideOverCard(isPresented: $isShowingCameraSOC, backgroundColor: (colorScheme == .dark ? Color(red: 28/255, green: 28/255, blue: 30/255) : Color.white)) {
            VStack {
                Text(LocalizedStringKey("FastPass")).font(Font.largeTitle.weight(.bold))
                Text(LocalizedStringKey("ScanQRCodeWithCamera"))
                
                CodeScannerView(codeTypes: [.qr], scanMode: .once, showViewfinder: false, shouldVibrateOnSuccess: true, completion: handleScan)
                    .frame(height: UIScreen.main.bounds.height * 0.25)
                    .cornerRadius(20)
                    .overlay {
                        if AVCaptureDevice.authorizationStatus(for: .video) == .denied || AVCaptureDevice.authorizationStatus(for: .video) == .restricted {
                            VStack {
                                Spacer()
                                Spacer()
                                Text(LocalizedStringKey("RequestUserPermitCamera"))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                Spacer()
                                Button {
                                    Constants.OpenInOS(forURL: URL(string: UIApplication.openSettingsURLString)!)
                                } label: {
                                    Text(LocalizedStringKey("OpenSettings"))
                                        .foregroundColor(.blue)
                                        .bold()
                                }
                                Spacer()
                                Spacer()
                            }
                            .padding(10)
                        }
                    }
                
                VStack(alignment: .leading) {
                    Text(LocalizedStringKey("ScanToGetToken")).bold()
                    Text(LocalizedStringKey("ScanToGetTokenContent"))
                        .foregroundColor(Color.gray)
                }
            }
        }
        .slideOverCard(isPresented: $isShowingManuallySOC, backgroundColor: (colorScheme == .dark ? Color(red: 28/255, green: 28/255, blue: 30/255) : Color.white)) {
            VStack {
                Text(LocalizedStringKey("FastPass")).font(Font.largeTitle.weight(.bold))
                Text(LocalizedStringKey("EnterTokenManually"))
                
                TextField("Token", text: $token)
                    .focused($focusedField, equals: .ManuallyToken)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(
                                (focusedField == .ManuallyToken ? .yellow : Color(red: 209/255, green: 209/255, blue: 213/255)),
                                lineWidth: (focusedField == .ManuallyToken ? 2 : 1))
                    )
                
                VStack(alignment: .leading) {
                    Text(LocalizedStringKey("EnterTokenManuallyContent"))
                        .foregroundColor(Color.gray)
                        .font(.caption)
                }
                
                Button(action: {
                    UIApplication.shared.endEditing()
                    isShowingManuallySOC.toggle()
                    Task {
                        isShowingTokenErrorAlert = !(await eventAPI.redeemToken(token: token))
                        print(isShowingTokenErrorAlert)
                    }
                }) {
                    HStack {
                        Spacer()
                        Text(LocalizedStringKey("Continue"))
                            .padding(.vertical, 20)
                            .foregroundColor(Color.white)
                        Spacer()
                    }.background(Color("LogoColor")).cornerRadius(12)
                }
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker { selectedImage in
                isShowingImagePicker = false
                if let result = extractFromQRCode(selectedImage) {
                    Task {
                        if !(await eventAPI.redeemToken(token: result)) {
                            DispatchQueue.main.async {
                                isShowingTokenErrorAlert = true
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        isShowingNoQRCodeAlert = true
                    }
                }
            }
        }
    }

    private func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingCameraSOC = false
        
        switch result {
        case .success(let result):
            Task {
                isShowingTokenErrorAlert = !(await eventAPI.redeemToken(token: result.string))
            }
            print(result.string)
        case .failure(let error):
            isShowingTokenErrorAlert.toggle()
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    private func extractFromQRCode(_ image: UIImage) -> String? {
        guard let ciImage = CIImage(image: image),
              let qrCodeDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil) else {
            return nil
        }
        let feature = qrCodeDetector.features(in: ciImage) as! [CIQRCodeFeature]
        return feature.first?.messageString
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#if DEBUG
struct RedeemTokenView_Previews: PreviewProvider {
    static var previews: some View {
        RedeemTokenView(eventAPI: OPassAPIViewModel.mock().currentEventAPI!)
    }
}
#endif
