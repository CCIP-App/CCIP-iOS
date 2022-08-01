//
//  AnnounceView.swift
//  OPass
//
//  Created by secminhr on 2022/3/5.
//  2022 OPass.
//

import SwiftUI

struct AnnounceView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    let display_text: DisplayTextModel
    @State var isShowingSafari = false
    @State var isError = false
    @Environment(\.colorScheme) var colorScheme
    
    init(eventAPI: EventAPIViewModel) {
        self.eventAPI = eventAPI
        self.display_text = eventAPI.eventSettings.feature(ofType: .announcement)?.display_text ?? .init(en: "", zh: "")
    }
    
    var body: some View {
        VStack {
            if !isError {
                if let announcements = eventAPI.eventAnnouncements {
                    if !announcements.isEmpty {
                        List(announcements, id: \.datetime) { announcement in
                            let url = URL(string: announcement.uri)
                            Button {
                                if let url = url {
                                    Constants.OpenInAppSafari(forURL: url, style: colorScheme)
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(LocalizeIn(zh: announcement.msg_zh, en: announcement.msg_en))
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                        Text(String(format: "%d/%d %d:%02d", announcement.datetime.month, announcement.datetime.day, announcement.datetime.hour, announcement.datetime.minute))
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    if url != nil {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .refreshable{ try? await eventAPI.loadAnnouncements() }
                        .task{ try? await eventAPI.loadAnnouncements() }
                    } else {
                        VStack {
                            Image(systemName: "tray.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width * 0.25)
                                .foregroundColor(Color("LogoColor"))
                            Text("EmptyAnnouncement")
                                .font(.title2)
                        }
                        .refreshable{ try? await eventAPI.loadAnnouncements() }
                        .task{ try? await eventAPI.loadAnnouncements() }
                    }
                } else {
                    ProgressView("Loading")
                        .task {
                            do { try await self.eventAPI.loadAnnouncements() }
                            catch { self.isError = true }
                        }
                }
            } else {
                ErrorWithRetryView {
                    self.isError = false
                    Task {
                        do { try await self.eventAPI.loadAnnouncements() }
                        catch { self.isError = true }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(LocalizeIn(zh: display_text.zh, en: display_text.en))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                SFButton(systemName: "arrow.clockwise") {
                    self.isError = false
                    self.eventAPI.eventAnnouncements = nil
                }
            }
        }
    }
}

#if DEBUG
struct AnnounceView_Previews: PreviewProvider {
    static var previews: some View {
        AnnounceView(eventAPI: OPassAPIViewModel.mock().currentEventAPI!)
    }
}
#endif
