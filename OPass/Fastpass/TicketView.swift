//
//  TicketView.swift
//  OPass
//
//  Created by 張智堯 on 2022/4/1.
//  2025 OPass.
//

import SwiftUI
import QRCode

struct TicketView: View {
    
    @EnvironmentObject var EventStore: EventStore
    @State private var isTokenVisible = false
    @State private var isLogOutAlertPresented = false
    @State private var qrCodeUIImage = UIImage()
    @State private var defaultBrightness = UIScreen.main.brightness
    @AppStorage("AutoAdjustTicketBirghtness") var autoAdjustTicketBirghtness = true
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            if let token = EventStore.token {
                VStack(spacing: 0) {
                    Form {
                        Section() {
                            HStack {
                                Spacer()
                                VStack(spacing: 0) {
                                    QRCodeViewUI(
                                        content: token,
                                        errorCorrection: .low,
                                        onPixelShape: QRCode.PixelShape.RoundedPath(
                                            cornerRadiusFraction: 1,
                                            hasInnerCorners: true
                                        ),
                                        eyeShape: QRCode.EyeShape.RoundedRect(cornerRadiusFraction: 0.6),
                                        logoTemplate: nil,
                                    )
                                    .frame(
                                        width: UIScreen.main.bounds.width * 0.55,
                                        height: UIScreen.main.bounds.width * 0.55
                                    )
                                }
                                .padding(UIScreen.main.bounds.width * 0.07)
                                .background(Color.white)
                                .cornerRadius(UIScreen.main.bounds.width * 0.1)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.clear)
                        
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
                    .onChange(of: scenePhase) {
                        if scenePhase == .active {
                            AutoAdjustBrightness()
                        } else {
                            ResetBrightness()
                        }
                    }
                    
                    Toggle("AutoBrighten", isOn: $autoAdjustTicketBirghtness)
                        .onChange(of: autoAdjustTicketBirghtness) {
                            if autoAdjustTicketBirghtness {
                                self.defaultBrightness = UIScreen.main.brightness
                                UIScreen.main.brightness = 1
                            } else { UIScreen.main.brightness = defaultBrightness }
                        }
                        .padding([.leading, .trailing])
                        .padding([.bottom, .top], 10)
                        .background(.sectionBackground)
                }
                .task { try? await EventStore.loadAttendee() }
            } else {
                RedeemTokenView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let displayText = EventStore.config.feature(.ticket)?.title {
                ToolbarItem(placement: .principal) {
                    Text(displayText.localized()).font(.headline)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if EventStore.token != nil {
                    Button(action: {
                        isLogOutAlertPresented.toggle()
                    }) { Text(LocalizedStringKey("SignOut")).foregroundColor(.red) }
                }
            }
        }
        .alert("ConfirmSignOut", isPresented: $isLogOutAlertPresented) {
            Button("SignOut", role: .destructive) {
                self.EventStore.signOut()
            }
            Button("Cancel", role: .cancel) { }
        }
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
