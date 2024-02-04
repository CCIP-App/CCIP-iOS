//
//  AnnouncementView.swift
//  OPass
//
//  Created by secminhr on 2022/3/5.
//  2024 OPass.
//

import SwiftUI

struct AnnouncementView: View {
    @EnvironmentObject var event: EventStore
    @State private var isHttp403AlertPresented = false
    @State private var errorType: String?
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            if errorType == nil {
                if let announcements = event.announcements {
                    if announcements.isNotEmpty {
                        List(announcements, id: \.datetime) { announcement in
                            Button {
                                if let url = announcement.url {
                                    Constants.openInAppSafari(forURL: url, style: colorScheme)
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
                                            .foregroundColor(.gray.opacity(0.56))
                                            .fontWeight(.semibold)
                                            .font(.callout)
                                    }
                                }
                            }
                        }
                        .refreshable {
                            do {
                                try await event.loadAnnouncements(reload: true)
                            } catch APIManager.LoadError.forbidden {
                                self.isHttp403AlertPresented = true
                            } catch {}
                        }
                        .task {
                            do {
                                try await event.loadAnnouncements()
                            } catch APIManager.LoadError.forbidden {
                                self.isHttp403AlertPresented = true
                            } catch {}
                        }
                    } else {
                        VStack {
                            Image(systemName: "tray.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width * 0.25)
                                .foregroundColor(.logo)
                            Text("EmptyAnnouncement")
                                .font(.title2)
                        }
                        .refreshable {
                            do {
                                try await event.loadAnnouncements(reload: true)
                            } catch APIManager.LoadError.forbidden {
                                self.isHttp403AlertPresented = true
                            } catch {}
                        }
                        .task {
                            do {
                                try await event.loadAnnouncements(reload: true)
                            } catch APIManager.LoadError.forbidden {
                                self.isHttp403AlertPresented = true
                            } catch {}
                        }
                    }
                } else {
                    ProgressView("Loading")
                        .task {
                            do {
                                try await self.event.loadAnnouncements()
                            } catch APIManager.LoadError.forbidden {
                                self.isHttp403AlertPresented = true
                                self.errorType = "http403"
                            } catch { self.errorType = "unknown" }
                        }
                }
            } else {
                ContentUnavailableView {
                    switch errorType! {
                    case "http403":
                        Label("Network Error", systemImage: "wifi.exclamationmark")
                    default:
                        Label("Something went wrong", systemImage: "exclamationmark.triangle.fill")
                    }
                } description: {
                    switch errorType! {
                    case "http403":
                        Text("ConnectToConferenceWiFi")
                    default:
                        Text("Check your network status or select a new event.")
                    }
                } actions: {
                    Button("Try Again") {
                        self.errorType = nil
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let displayText = event.config.feature(.announcement)?.title {
                ToolbarItem(placement: .principal) {
                    Text(displayText.localized()).font(.headline)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                SFButton(systemName: "arrow.clockwise") {
                    self.errorType = nil
                    self.event.announcements = nil
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
            .environmentObject(OPassStore.mock().event!)
    }
}
#endif
