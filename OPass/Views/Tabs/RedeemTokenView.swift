//
//  RedeemTokenView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/5.
//  2022 OPass.
//

import SwiftUI
import UIKit
import CodeScanner
import AVFoundation

struct RedeemTokenView: View {
    
    enum Field: Hashable {
        case ManuallyToken
    }
    
    @State var token: String = ""
    @ObservedObject var eventAPI: EventAPIViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var showCameraSOC = false
    @State var showImagePicker = false
    @State var showManuallySOC = false
    @State var showNoQRCodeAlert = false
    @State var showInvaildTokenAlert = false
    @State var showHttp403Alert = false
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack {
            Form {
                FastpassLogoView(eventAPI: eventAPI)
                    .frame(height: UIScreen.main.bounds.width * 0.4)
                    .listRowBackground(Color.white.opacity(0))
                
                Section {
                    Button(action: {
                        self.showCameraSOC = true
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
                    .alert("CouldntVerifiyYourIdentity", isPresented: $showInvaildTokenAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text("InvaildToken")
                    }
                    
                    Button(action: {
                        self.showImagePicker = true
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
                    .alert("NoQRCodeFoundInPicture", isPresented: $showNoQRCodeAlert) {
                        Button("OK", role: .cancel) {}
                    }
                    
                    Button(action: {
                        self.showManuallySOC = true
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
        .slideOverCard(isPresented: $showCameraSOC, backgroundColor: (colorScheme == .dark ? Color(red: 28/255, green: 28/255, blue: 30/255) : Color.white)) {
            VStack {
                Text(LocalizedStringKey("FastPass")).font(Font.largeTitle.weight(.bold))
                Text(LocalizedStringKey("ScanQRCodeWithCamera"))
                
                CodeScannerView(codeTypes: [.qr], scanMode: .once, showViewfinder: false, shouldVibrateOnSuccess: true, completion: HandleScan)
                    .frame(height: UIScreen.main.bounds.height * 0.25)
                    .cornerRadius(20)
                    .overlay {
                        if !(AVCaptureDevice.authorizationStatus(for: .video) == .authorized) {
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
        .slideOverCard(isPresented: $showManuallySOC, backgroundColor: (colorScheme == .dark ? Color(red: 28/255, green: 28/255, blue: 30/255) : Color.white)) {
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
                    Text("EnterTokenManuallyContent")
                        .foregroundColor(Color.gray)
                        .font(.caption)
                }
                
                Button(action: {
                    UIApplication.endEditing()
                    self.showManuallySOC = false
                    Task {
                        do {
                            self.showInvaildTokenAlert = !(try await eventAPI.redeemToken(token: token))
                        } catch APIRepo.LoadError.http403Forbidden {
                            self.showHttp403Alert = true
                        } catch {
                            self.showInvaildTokenAlert = true
                        }
                    }
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
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { image in
                self.showImagePicker = false
                if let result = ExtractQRCodeString(from: image) {
                    Task {
                        do {
                            let result = try await eventAPI.redeemToken(token: result)
                            DispatchQueue.main.async {
                                self.showInvaildTokenAlert = !result
                            }
                        } catch APIRepo.LoadError.http403Forbidden {
                            DispatchQueue.main.async {
                                self.showHttp403Alert = true
                            }
                        } catch {
                            DispatchQueue.main.async {
                                self.showInvaildTokenAlert = true
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showNoQRCodeAlert = true
                    }
                }
            }
        }
        .http403Alert(title: "CouldntVerifiyYourIdentity", isPresented: $showHttp403Alert)
    }

    private func HandleScan(result: Result<ScanResult, ScanError>) {
        self.showCameraSOC = false
        switch result {
        case .success(let result):
            Task {
                do {
                    let result = try await eventAPI.redeemToken(token: result.string)
                    DispatchQueue.main.async {
                        self.showInvaildTokenAlert = !result
                    }
                } catch APIRepo.LoadError.http403Forbidden {
                    DispatchQueue.main.async {
                        self.showHttp403Alert = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showInvaildTokenAlert = true
                    }
                }
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.showInvaildTokenAlert = true
            }
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    private func ExtractQRCodeString(from image: UIImage) -> String? {
        guard let ciImage = CIImage(image: image),
              let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil),
              let feature = detector.features(in: ciImage) as? [CIQRCodeFeature] else {
            return nil
        }
        return feature.first?.messageString
    }
}

#if DEBUG
struct RedeemTokenView_Previews: PreviewProvider {
    static var previews: some View {
        RedeemTokenView(eventAPI: OPassAPIViewModel.mock().currentEventAPI!)
    }
}
#endif
