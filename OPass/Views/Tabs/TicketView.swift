//
//  TicketView.swift
//  OPass
//
//  Created by 張智堯 on 2022/4/1.
//  2022 OPass.
//

import SwiftUI
import EFQRCode

struct TicketView: View {
    
    @EnvironmentObject var eventAPI: EventAPIViewModel
    @State private var isTokenVisible = false
    @State private var isLogOutAlertPresented = false
    @State private var qrCodeUIImage = UIImage()
    @State private var defaultBrightness = UIScreen.main.brightness
    @AppStorage("AutoAdjustTicketBirghtness") var autoAdjustTicketBirghtness = true
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            if let token = eventAPI.user_token {
                VStack(spacing: 0) {
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
                                }
                                .padding(UIScreen.main.bounds.width * 0.08)
                                .background(Color.white)
                                .cornerRadius(UIScreen.main.bounds.width * 0.1)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.transparent)
                        
                        Section(header: Text("Token"), footer: Text("TicketWarningContent")) {
                            HStack {
                                isTokenVisible
                                ? Text(token)
                                    .fixedSize(horizontal: false, vertical: true)
                                : Text(String(repeating: "•", count: token.count))
                                    .font(.title3).fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .onTapGesture { isTokenVisible.toggle() }
                        .contextMenu {
                            Button {
                                UIPasteboard.general.string = token
                            } label: {
                                Label("CopyToken", systemImage: "square.on.square")
                            }
                        }
                    }
                    .onAppear { AutoAdjustBrightness() }
                    .onDisappear { ResetBrightness() }
                    .onChange(of: scenePhase) { phase in
                        if phase == .active {
                            AutoAdjustBrightness()
                        } else {
                            ResetBrightness()
                        }
                    }
                    
                    Toggle("AutoBrighten", isOn: $autoAdjustTicketBirghtness)
                        .onChange(of: autoAdjustTicketBirghtness) { auto in
                            if auto {
                                self.defaultBrightness = UIScreen.main.brightness
                                UIScreen.main.brightness = 1
                            } else { UIScreen.main.brightness = defaultBrightness }
                        }
                        .padding([.leading, .trailing])
                        .padding([.bottom, .top], 10)
                        .background(Color("SectionBackgroundColor"))
                }
                .task { try? await eventAPI.loadScenarioStatus() }
            } else {
                RedeemTokenView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let displayText = eventAPI.settings.feature(ofType: .ticket)?.display_text {
                ToolbarItem(placement: .principal) {
                    Text(displayText.localized()).font(.headline)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if eventAPI.user_token != nil {
                    Button(action: {
                        isLogOutAlertPresented.toggle()
                    }) { Text(LocalizedStringKey("SignOut")).foregroundColor(.red) }
                }
            }
        }
        .alert("ConfirmSignOut", isPresented: $isLogOutAlertPresented) {
            Button("SignOut", role: .destructive) {
                self.eventAPI.signOut()
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private func renderQRCode(string: String) -> UIImage {
        let generator = EFQRCodeGenerator(content: string, encoding: .utf8, size: EFIntSize())
        
        generator.withInputCorrectionLevel(.h)
        generator.withColors(backgroundColor: UIColor.white.cgColor, foregroundColor: UIColor.black.cgColor)
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
    
    private func AutoAdjustBrightness() {
        if autoAdjustTicketBirghtness {
            UIScreen.main.brightness = 1
        }
    }
    private func ResetBrightness() {
        if autoAdjustTicketBirghtness {
            UIScreen.main.brightness = defaultBrightness
        }
    }
}
