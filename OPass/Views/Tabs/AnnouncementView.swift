//
//  AnnouncementView.swift
//  OPass
//
//  Created by secminhr on 2022/3/5.
//  2022 OPass.
//

import SwiftUI

struct AnnouncementView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    private let display_text: DisplayTextModel
    @State var showHttp403Alert = false
    @State var errorType: String? = nil
    @Environment(\.colorScheme) var colorScheme
    
    init(eventAPI: EventAPIViewModel) {
        self.eventAPI = eventAPI
        self.display_text = eventAPI.eventSettings.feature(ofType: .announcement)?.display_text ?? .init(en: "", zh: "")
    }
    
    var body: some View {
        VStack {
            if errorType == nil {
                if let announcements = eventAPI.eventAnnouncements {
                    if announcements.isNotEmpty {
                        List(announcements, id: \.datetime) { announcement in
                            let url = URL(string: announcement.uri)
                            Button {
                                if let url = url {
                                    Constants.OpenInAppSafari(forURL: url, style: colorScheme)
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(announcement.localized())
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
                        .refreshable{
                            do {
                                try await eventAPI.loadAnnouncements()
                            } catch APIRepo.LoadError.http403Forbidden {
                                self.showHttp403Alert = true
                            } catch {}
                        }
                        .task{
                            do {
                                try await eventAPI.loadAnnouncements()
                            } catch APIRepo.LoadError.http403Forbidden {
                                self.showHttp403Alert = true
                            } catch {}
                        }
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
                        .refreshable{
                            do {
                                try await eventAPI.loadAnnouncements()
                            } catch APIRepo.LoadError.http403Forbidden {
                                self.showHttp403Alert = true
                            } catch {}
                        }
                        .task{
                            do {
                                try await eventAPI.loadAnnouncements()
                            } catch APIRepo.LoadError.http403Forbidden {
                                self.showHttp403Alert = true
                            } catch {}
                        }
                    }
                } else {
                    ProgressView("Loading")
                        .task {
                            do { try await self.eventAPI.loadAnnouncements() }
                            catch APIRepo.LoadError.http403Forbidden {
                                self.showHttp403Alert = true
                                self.errorType = "http403"
                            } catch { self.errorType = "unknown" }
                        }
                }
            } else {
                ErrorWithRetryView(message: {
                    switch errorType! {
                    case "http403": return "ConnectToConferenceWiFi"
                    default: return nil
                    }
                }()) {
                    self.errorType = nil
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(display_text.localized())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                SFButton(systemName: "arrow.clockwise") {
                    self.errorType = nil
                    self.eventAPI.eventAnnouncements = nil
                }
            }
        }
        .http403Alert(isPresented: $showHttp403Alert)
    }
}

#if DEBUG
struct AnnounceView_Previews: PreviewProvider {
    static var previews: some View {
        AnnouncementView(eventAPI: OPassAPIViewModel.mock().currentEventAPI!)
    }
}
#endif
