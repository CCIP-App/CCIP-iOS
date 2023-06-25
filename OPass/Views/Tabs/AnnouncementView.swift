//
//  AnnouncementView.swift
//  OPass
//
//  Created by secminhr on 2022/3/5.
//  2023 OPass.
//

import SwiftUI

struct AnnouncementView: View {
    
    @EnvironmentObject var EventService: EventService
    @State private var isHttp403AlertPresented = false
    @State private var errorType: String? = nil
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            if errorType == nil {
                if let announcements = EventService.announcements {
                    if announcements.isNotEmpty {
                        List(announcements, id: \.datetime) { announcement in
                            Button {
                                if let url = announcement.url {
                                    Constants.OpenInAppSafari(forURL: url, style: colorScheme)
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(announcement.localized())
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                        Text(String(
                                            format: "%d/%d %d:%02d",
                                            announcement.datetime.month,
                                            announcement.datetime.day,
                                            announcement.datetime.hour,
                                            announcement.datetime.minute
                                        ))
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    if announcement.url != nil {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .refreshable{
                            do {
                                try await EventService.loadAnnouncements()
                            } catch APIRepo.LoadError.forbidden {
                                self.isHttp403AlertPresented = true
                            } catch {}
                        }
                        .task{
                            do {
                                try await EventService.loadAnnouncements()
                            } catch APIRepo.LoadError.forbidden {
                                self.isHttp403AlertPresented = true
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
                                try await EventService.loadAnnouncements()
                            } catch APIRepo.LoadError.forbidden {
                                self.isHttp403AlertPresented = true
                            } catch {}
                        }
                        .task{
                            do {
                                try await EventService.loadAnnouncements()
                            } catch APIRepo.LoadError.forbidden {
                                self.isHttp403AlertPresented = true
                            } catch {}
                        }
                    }
                } else {
                    ProgressView("Loading")
                        .task {
                            do { try await self.EventService.loadAnnouncements() }
                            catch APIRepo.LoadError.forbidden {
                                self.isHttp403AlertPresented = true
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let displayText = EventService.settings.feature(ofType: .announcement)?.display_text {
                ToolbarItem(placement: .principal) {
                    Text(displayText.localized()).font(.headline)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                SFButton(systemName: "arrow.clockwise") {
                    self.errorType = nil
                    self.EventService.announcements = nil
                }
            }
        }
        .http403Alert(isPresented: $isHttp403AlertPresented)
    }
}

#if DEBUG
struct AnnounceView_Previews: PreviewProvider {
    static var previews: some View {
        AnnouncementView()
            .environmentObject(OPassService.mock().currentEventAPI!)
    }
}
#endif
