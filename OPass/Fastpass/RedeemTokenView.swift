//
//  RedeemTokenView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/5.
//  2023 OPass.
//

import SwiftUI
import PhotosUI
import CodeScanner

struct RedeemTokenView: View {
    
    @EnvironmentObject var EventStore: EventStore
    @State private var token: String = ""
    @State private var isCameraSOCPresented = false
    @State private var isManuallySOCPresented = false
    @State private var isHttp403AlertPresented = false
    @State private var isNoQRCodeAlertPresented = false
    @State private var isInvaildTokenAlertPresented = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @FocusState private var focusedField: Field?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            Form {
                FastpassLogoView()
                    .frame(height: UIScreen.main.bounds.width * 0.4)
                    .listRowBackground(Color.white.opacity(0))
                
                Section {
                    Button { self.isCameraSOCPresented = true } label: {
                        HStack {
                            Image(systemName: "camera")
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(9)
                            Text("ScanQRCodeWithCamera")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .any(of: [.images, .not(.livePhotos)])) {
                        HStack {
                            Image(systemName: "photo")
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .cornerRadius(9)
                            Text("SelectAPictureToScanQRCode")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                    .alert("NoQRCodeFoundInPicture", isPresented: $isNoQRCodeAlertPresented)
                    
                    Button { self.isManuallySOCPresented = true } label: {
                        HStack {
                            Image(systemName: "keyboard")
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 10)
                                .background(Color.purple)
                                .cornerRadius(9)
                            Text("EnterTokenManually")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .http403Alert(title: "CouldntVerifiyYourIdentity", isPresented: $isHttp403AlertPresented)
        .alert("CouldntVerifiyYourIdentity", message: "InvaildToken", isPresented: $isInvaildTokenAlertPresented)
        .slideOverCard(isPresented: $isCameraSOCPresented, backgroundColor: (colorScheme == .dark ? .init(red: 28/255, green: 28/255, blue: 30/255) : .white)) {
            VStack {
                Text("FastPass").font(Font.largeTitle.weight(.bold))
                Text("ScanQRCodeWithCamera")
                
                CodeScannerView(codeTypes: [.qr], scanMode: .once, showViewfinder: false, shouldVibrateOnSuccess: true, completion: HandleScan)
                    .frame(height: UIScreen.main.bounds.height * 0.25)
                    .cornerRadius(20)
                    .overlay {
                        if !(AVCaptureDevice.authorizationStatus(for: .video) == .authorized) {
                            VStack {
                                Spacer()
                                Spacer()
                                Text("RequestUserPermitCamera")
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                Spacer()
                                Button {
                                    Constants.openInOS(forURL: URL(string: UIApplication.openSettingsURLString)!)
                                } label: {
                                    Text("OpenSettings")
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
                    Text("ScanToGetToken").bold()
                    Text("ScanToGetTokenContent")
                        .foregroundColor(Color.gray)
                }
            }
        }
        .slideOverCard(
            isPresented: $isManuallySOCPresented,
            onDismiss: { UIApplication.endEditing() },
            backgroundColor: (colorScheme == .dark ? .init(red: 28/255, green: 28/255, blue: 30/255) : .white)
        ) {
            VStack {
                Text("FastPass").font(Font.largeTitle.weight(.bold))
                Text("EnterTokenManually")
                
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
                    self.isManuallySOCPresented = false
                    Task {
                        do {
                            self.isInvaildTokenAlertPresented = !(try await EventStore.redeem(token: token))
                        } catch APIManager.LoadError.forbidden {
                            self.isHttp403AlertPresented = true
                        } catch {
                            self.isInvaildTokenAlertPresented = true
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
        .onChange(of: selectedPhotoItem) {
            Task {
                guard let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self),
                      let ciImage = CIImage(data: data),
                      let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil),
                      let feature = detector.features(in: ciImage) as? [CIQRCodeFeature],
                      let token = feature.first?.messageString
                else { self.isNoQRCodeAlertPresented = true; return }
                do {
                    let result = try await EventStore.redeem(token: token)
                    self.isInvaildTokenAlertPresented = !result
                } catch APIManager.LoadError.forbidden {
                    self.isHttp403AlertPresented = true
                } catch { self.isInvaildTokenAlertPresented = true }
            }
        }
    }
    
    private func HandleScan(result: Result<ScanResult, ScanError>) {
        self.isCameraSOCPresented = false
        switch result {
        case .success(let result):
            Task {
                do {
                    let result = try await EventStore.redeem(token: result.string)
                    DispatchQueue.main.async {
                        self.isInvaildTokenAlertPresented = !result
                    }
                } catch APIManager.LoadError.forbidden {
                    DispatchQueue.main.async {
                        self.isHttp403AlertPresented = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isInvaildTokenAlertPresented = true
                    }
                }
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.isInvaildTokenAlertPresented = true
            }
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    enum Field: Hashable {
        case ManuallyToken
    }
}

#if DEBUG
struct RedeemTokenView_Previews: PreviewProvider {
    static var previews: some View {
        RedeemTokenView()
            .environmentObject(OPassStore.mock().event!)
    }
}
#endif
