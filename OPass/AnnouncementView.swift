//
//  AnnouncementView.swift
//  OPass
//
//  Created by Brian Chang on 2025/3/22.
//  2025 OPass.
//

import SwiftUI
import SwiftDate

struct AnnouncementView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var event: EventStore
    @State private var viewModel = ViewModel()
    
    // MARK: - Views
    var body: some View {
        VStack {
            if viewModel.errorType == nil {
                if let announcements = event.announcements {
                    if !announcements.isEmpty {
                        announcementListView(announcements)
                    } else { emptyView() }
                } else { loadingView() }
            } else { errorView() }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarItems() }
        .http403Alert(isPresented: $viewModel.isHttp403AlertPresented)
    }
    
    private func announcementListView(_ announcements: [Announcement]) -> some View {
        Form {
            ForEach(announcements, id: \.datetime) { announcement in
                Section {
                    Button {
                        if let url = announcement.url {
                            Constants.openInAppSafari(forURL: url, style: colorScheme)
                        }
                    } label: {
                        HStack {
                            Rectangle()
                                .fill(Color.accentColor)
                                .frame(width: 3)
                                .cornerRadius(2)
                                .padding(.vertical, 5)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(announcement.localized())
                                    .font(.headline)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                HStack {
                                    HStack(spacing: 4) {
                                        Image(systemName: "calendar")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        Text(formatDate(announcement.datetime))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    if announcement.url != nil {
                                        Spacer()
                                        
                                        Text("View Details")
                                            .font(.caption)
                                            .foregroundColor(.accentColor)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.accentColor.opacity(0.15))
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listRowInsets(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
        }
        .listSectionSpacing(.compact)
        .contentMargins(.top, 15)
        .shadow(color: .gray.opacity(colorScheme == .dark ? 0 : 0.35), radius: 7, x: 3, y: 3)
        .scrollContentBackground(.hidden)
        .background(Color(.systemBackground))
        .refreshable {
            await viewModel.loadAnnouncements(event: event, reload: true)
        }
    }
    
    private func emptyView() -> some View {
        ContentUnavailableView {
            Label {
                Text("Empty Announcement")
            } icon: {
                Image(systemName: "bell.badge")
                    .foregroundStyle(.blue)
                    .symbolEffect(.pulse)
            }
        } description: {
            Text("Check back later for announcements")
        } actions: {
            Button {
                viewModel.reset()
                event.announcements = nil
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 5)
                    .padding(.vertical, 3)
            }
            .buttonBorderShape(.roundedRectangle)
            .buttonStyle(.bordered)
            .tint(.blue)
        }
    }
    
    private func loadingView() -> some View {
        ProgressView("Loading Announcements...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task { await viewModel.loadAnnouncements(event: event) }
    }
    
    private func errorView() -> some View {
        ContentUnavailableView {
            Label {
                Text(viewModel.errorType == "http403" ? "Network Error" : "Something Went Wrong")
            } icon: {
                Image(systemName: viewModel.errorType == "http403" ? "wifi.exclamationmark" : "exclamationmark.triangle.fill")
                    .foregroundStyle(.blue)
                    .symbolEffect(.pulse)
            }
        } description: {
            Text(viewModel.errorType == "http403" ? "Please connect to the Wi-Fi provided by event" : "Check your network status or select a new event.")
        } actions: {
            Button {
                viewModel.reset()
                event.announcements = nil
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 5)
                    .padding(.vertical, 3)
            }
            .buttonBorderShape(.roundedRectangle)
            .buttonStyle(.bordered)
            .tint(.blue)
        }
    }
    
    private func formatDate(_ datetime: DateInRegion) -> String {
        return String(
            format: "%d/%d/%d - %d:%02d",
            datetime.year,
            datetime.month,
            datetime.day,
            datetime.hour,
            datetime.minute
        )
    }
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private func toolbarItems() -> some ToolbarContent {
        if let displayText = event.config.feature(.announcement)?.title {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text(displayText.localized())
                        .font(.headline)
                    
                    if let announcementCount = event.announcements?.count, announcementCount > 0 {
                        Text("\(announcementCount) \(announcementCount == 1 ? "announcement" : "announcements")")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }
}

// MARK: - ViewModel
extension AnnouncementView {
    @Observable
    class ViewModel {
        var isLoading = false
        var errorType: String?
        var isHttp403AlertPresented = false
        
        func loadAnnouncements(event: EventStore, reload: Bool = false) async {
            if isLoading { return }
            
            isLoading = true
            errorType = nil
            
            do {
                try await event.loadAnnouncements(reload: reload)
            } catch APIManager.LoadError.forbidden {
                errorType = "http403"
                isHttp403AlertPresented = true
            } catch { errorType = "unknown" }
            
            isLoading = false
        }
        
        func reset() {
            errorType = nil
        }
    }
}

#Preview {
    AnnouncementView()
}
