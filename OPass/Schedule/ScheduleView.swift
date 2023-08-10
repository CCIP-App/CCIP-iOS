//
//  ScheduleView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//  2023 OPass.
//

import SwiftUI
import SwiftDate
import OrderedCollections

enum ScheduleFilter: Hashable {
    case all
    case liked
    case tag(String)
    case type(String)
    case room(String)
    case speaker(String)
}

struct ScheduleContainerView: View {
    @EnvironmentObject private var event: EventStore

    @State private var selectDayIndex = 0
    @State private var didAppear = false
    @State private var filter = ScheduleFilter.all
    @State private var isError = false

    @AppStorage("AutoSelectScheduleDay") private var autoSelectScheduleDay = true

    var body: some View {
        ScheduleView(
            selectDayIndex: $selectDayIndex,
            filter: $filter,
            isError: $isError,
            filteredSessions: filteredSessions,
            initialize: initialize)
        .navigationDestination(for: ScheduleDestinations.self) { $0.view }
        .onAppear {
            guard !didAppear else { return }
            didAppear.toggle()
            guard autoSelectScheduleDay else { return }
            selectDayIndex = event.schedule?.sessions.firstIndex { $0.keys[0].isToday } ?? 0
        }
    }

    private var filteredSessions: OrderedDictionary<DateInRegion, [Session]>? {
        guard let schedule = event.schedule else { return nil }
        guard filter != .all else { return schedule.sessions[selectDayIndex] }
        return schedule.sessions[selectDayIndex].compactMapValues { sessions in
            let sessions = sessions.filter { session in
                switch filter {
                case .liked: return event.likedSessions.contains(session.id)
                case .tag(let tag): return session.tags.contains(tag)
                case .type(let type): return session.type == type
                case .room(let room): return session.room == room
                case .speaker(let speaker): return session.speakers.contains(speaker)
                default: return false
                }
            }
            return sessions.isEmpty ? nil : sessions
        }
    }

    private func initialize() async {
        do {
            try await event.loadSchedule()
            if event.schedule?.sessions.count ?? 0 > 1, autoSelectScheduleDay{
                self.selectDayIndex = event.schedule?.sessions.firstIndex { $0.keys[0].isToday } ?? 0
            }
        }
        catch { isError = true }
    }
}

struct ScheduleView: View {
    @EnvironmentObject var event: EventStore

    @Binding var selectDayIndex: Int
    @Binding var filter: ScheduleFilter
    @Binding var isError: Bool

    var filteredSessions: OrderedDictionary<DateInRegion, [Session]>?
    let initialize: () async -> Void
    
    var body: some View {
        VStack {
            if !isError {
                if let schedule = event.schedule, let filteredSessions = filteredSessions {
                    VStack(spacing: 0) {
                        if schedule.sessions.count > 1 {
                            SelectDayView(selectDayIndex: $selectDayIndex, sessions: schedule.sessions)
                                .background(Color("SectionBackgroundColor"))
                        }
                        Form {
                            ForEach(filteredSessions.keys.sorted(), id: \.self) { header in
                                Section {
                                    ForEach(filteredSessions[header]!) { session in
                                        NavigationLink(value: ScheduleDestinations.session(session)) {
                                            SessionOverView(session: session)
                                        }
                                    }
                                }
                                .listRowInsets(.init(top: 10, leading: 15, bottom: 10, trailing: 15))
                            }
                        }
                        .refreshable { try? await event.loadSchedule() }
                        .overlay {
                            if filteredSessions.isEmpty {
                                VStack(alignment: .center) {
                                    Image(systemName: "text.badge.xmark")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(Color("LogoColor"))
                                        .frame(width: UIScreen.main.bounds.width * 0.15)
                                        .padding(.bottom)
                                    
                                    Text(LocalizedStringKey("NoFilteredEvent"))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                } else {
                    ProgressView(LocalizedStringKey("Loading"))
                        .task { await initialize() }
                }
            } else {
                ErrorWithRetryView {
                    self.isError = false
                    Task { await initialize() }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(event.config.feature(.schedule)?.title.localized() ?? "Schedule").font(.headline)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if let schedule = event.schedule {
                        NavigationLink(value: ScheduleDestinations.search(schedule)) {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                    
                    Menu {
                        Picker(selection: $filter, label: EmptyView()) {
                            Label("AllSessions", systemImage: "list.bullet")
                                .tag(ScheduleFilter.all)
                            
                            Label("Favorite", systemImage: "heart")
                                .symbolVariant(filter == .liked ? .fill : .none)
                                .tag(ScheduleFilter.liked)
                            
                            if let schedule = event.schedule, !schedule.tags.isEmpty {
                                Menu {
                                    Picker(selection: $filter, label: EmptyView()) {
                                        ForEach(schedule.tags.keys, id: \.self) { id in
                                            Text(schedule.tags[id]?.localized().name ?? id)
                                                .tag(ScheduleFilter.tag(id))
                                        }
                                    }
                                } label: {
                                    Label("Tags", systemImage: {
                                        switch filter {
                                        case .tag(_):
                                            return "tag.fill"
                                        default:
                                            return "tag"
                                        }
                                    }())
                                }
                            }
                            
                            if let schedule = event.schedule, !schedule.types.isEmpty {
                                Menu {
                                    Picker(selection: $filter, label: EmptyView()) {
                                        ForEach(schedule.types.keys, id: \.self) { id in
                                            Text(schedule.types[id]?.localized().name ?? id)
                                                .tag(ScheduleFilter.type(id))
                                        }
                                    }
                                } label: {
                                    Label("Types", systemImage: {
                                        switch filter {
                                        case .type(_):
                                            return "signpost.right.fill"
                                        default:
                                            return "signpost.right"
                                        }
                                    }())
                                }
                            }
                            
                            if let schedule = event.schedule, !schedule.rooms.isEmpty {
                                Menu {
                                    Picker(selection: $filter, label: EmptyView()) {
                                        ForEach(schedule.rooms.keys, id: \.self) { id in
                                            Text(schedule.rooms[id]?.localized().name ?? id)
                                                .tag(ScheduleFilter.room(id))
                                        }
                                    }
                                } label: {
                                    Label("Places", systemImage: {
                                        switch filter {
                                        case .room(_): return "map.fill"
                                        default: return "map"
                                        }
                                    }())
                                }
                            }
                            
                            if let schedule = event.schedule, !schedule.speakers.isEmpty {
                                Menu {
                                    Picker(selection: $filter, label: EmptyView()) {
                                        ForEach(schedule.speakers.keys, id: \.self) { id in
                                            Text(schedule.speakers[id]?.localized().name ?? id)
                                                .tag(ScheduleFilter.speaker(id))
                                        }
                                    }
                                } label: {
                                    Label("Speakers", systemImage: {
                                        switch filter {
                                        case .speaker(_): return "person.fill"
                                        default: return "person"
                                        }
                                    }())
                                }
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.inline)
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .symbolVariant(filter == .all ? .none : .fill)
                    }
                }
            }
        }
    }
}

private struct SelectDayView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectDayIndex: Int
    let sessions: [OrderedDictionary<DateInRegion, [Session]>]
    private let weekDayName: [LocalizedStringKey] = ["SUN", "MON", "TUE", "WEN", "THR", "FRI", "SAT"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                ForEach(0 ..< sessions.count, id: \.self) { index in
                    Button {
                        self.selectDayIndex = index
                    } label: {
                        VStack(alignment: .center, spacing: 0) {
                            Text(weekDayName[sessions[index].keys[0].weekday - 1])
                                .font(.system(.subheadline, design: .monospaced))
                            Text(String(sessions[index].keys[0].day))
                                .font(.system(.body, design: .monospaced))
                        }
                        .foregroundColor(index == selectDayIndex ?
                                         (colorScheme == .dark ? Color.white : Color.white) :
                                            (colorScheme == .dark ? Color.white : Color.black))
                        .padding(8)
                        .background(Color.blue.opacity(index == selectDayIndex ? 1 : 0))
                        .cornerRadius(10)
                    }
                }
            }
            Divider().padding(.top, 13)
        }
        .frame(maxWidth: .infinity)
    }
}
