//
//  EventListView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//  2022 OPass.
//

import SwiftUI
import OSLog

struct EventListView: View {
    
    @EnvironmentObject var OPassAPI: OPassAPIViewModel
    @Environment(\.dismiss) var dismiss
    @State var isError = false
    
    var body: some View {
        NavigationView {
            VStack {
                if !isError {
                    if !OPassAPI.eventList.isEmpty {
                        Form {
                            ForEach(OPassAPI.eventList, id: \.event_id) { list in
                                EventRow(url: list.logo_url, displayName: list.display_name) {
                                    OPassAPI.currentEventID = list.event_id
                                    dismiss()
                                }
                            }
                        }
                    } else { ProgressView("Loading") }
                } else {
                    ErrorWithRetryView {
                        self.isError = false
                        Task {
                            do { try await self.OPassAPI.loadEventList() }
                            catch { self.isError = true }
                        }
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("SelectEvent"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if OPassAPI.currentEventAPI != nil {
                        Button(LocalizedStringKey("Close")) {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    SFButton(systemName: "arrow.clockwise") {
                        self.isError = false
                        Task {
                            do { try await self.OPassAPI.loadEventList() }
                            catch {
                                if self.OPassAPI.eventList.isEmpty { self.isError = true }
                            }
                        }
                    }
                }
            }
        }
        .task {
            do { try await OPassAPI.loadEventList() }
            catch { isError = true }
        }
        .interactiveDismissDisabled(OPassAPI.currentEventID == nil)
    }
}

private struct EventRow: View {
    let url: String
    let displayName: DisplayTextModel
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    private let logger = Logger(subsystem: "app.opass.ccip", category: "EventListView")
    var body: some View {
        Button(action: action) {
            HStack {
                AsyncImage(url: URL(string: url), transaction: Transaction(animation: .spring())) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .renderingMode(.template)
                            .resizable().scaledToFit()
                            .foregroundColor(Color("LogoColor"))
                    case .failure(_):
                        Image(systemName: "xmark.circle")
                            .foregroundColor(Color("LogoColor").opacity(0.5))
                    @unknown default:
                        Image(systemName: "xmark.circle")
                            .foregroundColor(Color("LogoColor").opacity(0.5))
                            .onAppear {
                                logger.error("Unknow AsyncImage status, please call developer to update")
                                
                            }
                    }
                }
                .padding(.horizontal, 3)
                .frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.width * 0.15)
                
                Text(LocalizeIn(zh: displayName.zh, en: displayName.en))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
    }
    
    
}

#if DEBUG
struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventListView()
                .environmentObject(OPassAPIViewModel.mock())
        }
        .navigationTitle(LocalizedStringKey("SelectEvent"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(LocalizedStringKey("Close")) {}
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                SFButton(systemName: "arrow.clockwise") {}
            }
        }
    }
}
#endif
