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
import simd

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

    @State private var selectedDay: Int? = 0
    @State private var didAppear = false
    @State private var filter = ScheduleFilter.all
    @State private var isError = false

    @AppStorage("AutoSelectScheduleDay") private var autoSelectScheduleDay = true

    var body: some View {
        ScheduleView(
            selectedDay: $selectedDay,
            filter: $filter,
            isError: $isError,
            filteredSessions: filteredSessions,
            initialize: initialize)
        .navigationDestination(for: ScheduleDestinations.self) { $0.view }
        .onAppear {
            guard !didAppear else { return }
            didAppear.toggle()
            guard autoSelectScheduleDay else { return }
            selectedDay = event.schedule?.sessions.firstIndex { $0.keys[0].isToday } ?? 0
        }
    }

    private var filteredSessions: [OrderedDictionary<DateInRegion, [Session]>]? {
        guard let allSessions = event.schedule?.sessions else { return nil }
        guard filter != .all else { return allSessions }
        return allSessions.map { daySessions in
            daySessions.compactMapValues { sessions in
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
    }

    private func initialize() async {
        do {
            try await event.loadSchedule()
            if event.schedule?.sessions.count ?? 0 > 1, autoSelectScheduleDay{
                self.selectedDay = event.schedule?.sessions.firstIndex { $0.keys[0].isToday } ?? 0
            }
        }
        catch { isError = true }
    }
}

struct ScheduleView: View {
    @EnvironmentObject private var event: EventStore
    @EnvironmentObject private var router: Router

    @State var tabProgress: CGFloat = 0
    @Binding var selectedDay: Int?
    @Binding var filter: ScheduleFilter
    @Binding var isError: Bool

    var filteredSessions: [OrderedDictionary<DateInRegion, [Session]>]?
    let initialize: () async -> Void
    
    var body: some View {
        VStack {
            if !isError {
                if let schedule = event.schedule, let filteredSessions = filteredSessions {
                    VStack(spacing: 0) {
                        if schedule.sessions.count > 1 {
                            SelectDayView(tabProgress: $tabProgress, selectedDay: $selectedDay, sessions: schedule.sessions)
                                .background(.sectionBackground)
                                .frame(maxWidth: .infinity)
                        }
                        GeometryReader {
                            let size = $0.size

                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 0) {
                                    ForEach(0 ..< filteredSessions.count, id: \.self) { day in
                                        ScrollView(.vertical) {
                                            LazyVStack {
                                                ForEach(filteredSessions[day].keys, id: \.self) { header in
                                                    LazyVStack(alignment: .leading, spacing: 0) {
                                                        ForEach(0 ..< filteredSessions[day][header]!.count, id: \.self) { index in
                                                            VStack(spacing: 0) {
                                                                if (index != 0) { Divider() }
                                                                Button {
                                                                    self.router.forward(ScheduleDestinations.session(filteredSessions[day][header]![index]))
                                                                } label: {
                                                                    SessionOverView(session: filteredSessions[day][header]![index])
                                                                        .padding(.vertical, 10)
                                                                        .padding(.horizontal, 15)
                                                                }
                                                            }
                                                        }
                                                    }
                                                    .background(.sectionBackground)
                                                    .cornerRadius(10)
                                                    .padding(.bottom)
                                                }
                                            }
                                            .padding()
                                            .id(day)
                                        }
                                        .refreshable { try? await event.loadSchedule(reload: true) }
                                        .containerRelativeFrame(.horizontal)
                                        .scrollIndicators(.automatic)
                                        .overlay {
                                            if filteredSessions[day].isEmpty {
                                                VStack(alignment: .center) {
                                                    Image(systemName: "text.badge.xmark")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundColor(.logo)
                                                        .frame(width: UIScreen.main.bounds.width * 0.15)
                                                        .padding(.bottom)

                                                    Text(LocalizedStringKey("NoFilteredEvent"))
                                                        .multilineTextAlignment(.center)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                        }
                                    }
                                }
                                .scrollTargetLayout()
                                .overlay {
                                    GeometryReader {
                                        Color.clear
                                            .preference(key: OffsetKey.self, value: $0.frame(in: .scrollView(axis: .horizontal)).minX)
                                            .onPreferenceChange(OffsetKey.self) { value in
                                                tabProgress = max(min(-value / (size.width * CGFloat(filteredSessions.count - 1)), 1), 0)
                                            }
                                    }
                                }
                            }
                            .scrollDisabled(schedule.sessions.count == 1)
                            .scrollPosition(id: $selectedDay)
                            .scrollTargetBehavior(.paging)
                            .scrollIndicators(.never)
                            .ignoresSafeArea(.all, edges: .bottom)
                            .background(.listBackground)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .toolbar { toolbar }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(event.config.feature(.schedule)?.title.localized() ?? "Schedule").font(.headline)
        }

        if let schedule = event.schedule {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    NavigationLink(value: ScheduleDestinations.search(schedule)) {
                        Image(systemName: "magnifyingglass")
                    }

                    Menu {
                        Picker(selection: $filter, label: EmptyView()) {
                            Label("AllSessions", systemImage: "list.bullet")
                                .tag(ScheduleFilter.all)

                            Label("Favorite", systemImage: "heart")
                                .symbolVariant(filter == .liked ? .fill : .none)
                                .tag(ScheduleFilter.liked)

                            if !schedule.tags.isEmpty {
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
                                        case .tag(_): return "tag.fill"
                                        default: return "tag"
                                        }
                                    }())
                                }
                            }

                            if !schedule.types.isEmpty {
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
                                        case .type(_): return "signpost.right.fill"
                                        default: return "signpost.right"
                                        }
                                    }())
                                }
                            }

                            if !schedule.rooms.isEmpty {
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

                            if !schedule.speakers.isEmpty {
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
    @Binding var tabProgress: CGFloat
    @Binding var selectedDay: Int?
    let sessions: [OrderedDictionary<DateInRegion, [Session]>]
    private let weekDayName: [LocalizedStringKey] = ["SUN", "MON", "TUE", "WEN", "THR", "FRI", "SAT"]
    private let colorGray = simd_double3(0.55686, 0.55686, 0.57647), colorWhite = simd_double3(1.0, 1.0, 1.0), colorBlack = simd_double3(0.0, 0.0, 0.0)

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0 ..< sessions.count, id: \.self) { index in
                    Button {
                        withAnimation { self.selectedDay = index }
                    } label: {
                        HStack {
                            Text("\(sessions[index].keys[0].month)/\(sessions[index].keys[0].day)")
                            Text(weekDayName[sessions[index].keys[0].weekday - 1])
                        }
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(caculateColor(index))
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 10)
                        .padding(.top, 2)
                    }
                }
            }
            .background {
                GeometryReader {
                    let size = $0.size
                    let lineWidth = size.width / CGFloat(sessions.count)

                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(.blue)
                            .frame(width: lineWidth, height: 2)
                    }
                    .offset(x: tabProgress * (size.width - lineWidth))
                }
            }
            Divider()
        }
        .frame(maxWidth: .infinity)
    }
    
    private func caculateColor(_ index: Int) -> Color {
        let factor = min(abs(Float(tabProgress) - (Float(index) / Float(sessions.count - 1))) * 2.0 * Float(sessions.count - 1), 1.0)
        let color = (colorScheme == .dark ? colorWhite : colorBlack) * Double(1.0 - factor) + colorGray * Double(factor)
        return .init(red: color.x, green: color.y, blue: color.z)
    }
}

private struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
