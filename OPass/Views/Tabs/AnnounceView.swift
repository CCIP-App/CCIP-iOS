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
    @State var showHttp403Alert = false
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
                                self.isError = true
                            } catch { self.isError = true }
                        }
                }
            } else {
                ErrorWithRetryView {
                    self.isError = false
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
        .http403Alert(isPresented: $showHttp403Alert)
    }
}

#if DEBUG
struct AnnounceView_Previews: PreviewProvider {
    static var previews: some View {
        AnnounceView(eventAPI: OPassAPIViewModel.mock().currentEventAPI!)
    }
}
#endif
