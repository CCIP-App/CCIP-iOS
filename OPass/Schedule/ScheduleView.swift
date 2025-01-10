//
//  ScheduleView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//  2025 OPass.
//

import OrderedCollections
import SwiftDate
import SwiftUI

struct ScheduleFilter: Hashable {
    var speaker: Set<String> = []
    var type: Set<String> = []
    var room: Set<String> = []
    var tag: Set<String> = []
    var liked = false
    var count = 0
}

struct ScheduleContainerView: View {
    @EnvironmentObject private var event: EventStore

    @State private var selectedDay: Int? = 0
    @State private var didAppear = false
    @State private var filters = ScheduleFilter()
    @State private var isError = false

    @AppStorage("AutoSelectScheduleDay") private var autoSelectScheduleDay = true

    var body: some View {
        ScheduleView(
            selectedDay: $selectedDay,
            filters: $filters,
            isError: $isError,
            filteredSessions: filteredSessions,
            initialize: initialize
        )
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
        guard filters.count != 0 else { return allSessions }
        return allSessions.map { daySessions in
            daySessions.compactMapValues { sessions in
                let sessions = sessions.filter { session in
                    if !filters.speaker.isEmpty, filters.speaker.isDisjoint(with: session.speakers) { return false }
                    if !filters.type.isEmpty, let type = session.type, !filters.type.contains(type) { return false }
                    if !filters.room.isEmpty, !filters.room.contains(session.room) { return false }
                    if !filters.tag.isEmpty, filters.tag.isDisjoint(with: session.tags) { return false }
                    if filters.liked, !event.likedSessions.contains(session.id) { return false }
                    return true
                }
                return sessions.isEmpty ? nil : sessions
            }
        }
    }

    private func initialize() async {
        do {
            try await event.loadSchedule()
            if event.schedule?.sessions.count ?? 0 > 1, autoSelectScheduleDay {
                self.selectedDay = event.schedule?.sessions.firstIndex { $0.keys[0].isToday } ?? 0
            }
        } catch { isError = true }
    }
}

struct ScheduleView: View {
    @EnvironmentObject private var event: EventStore
    @EnvironmentObject private var router: Router

    @State var tabProgress: CGFloat = 0
    @Binding var selectedDay: Int?
    @Binding var filters: ScheduleFilter
    @Binding var isError: Bool

    var filteredSessions: [OrderedDictionary<DateInRegion, [Session]>]?
    let initialize: () async -> Void

    var body: some View {
        Group {
            if !isError {
                if let schedule = event.schedule, let filteredSessions = filteredSessions {
                    VStack(spacing: 0) {
                        if schedule.sessions.count > 1 {
                            SelectDayView(
                                tabProgress: $tabProgress, selectedDay: $selectedDay,
                                sessions: schedule.sessions
                            )
                            .background(.sectionBackground)
                            .frame(maxWidth: .infinity)
                        }
                        GeometryReader {
                            let size = $0.size
                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 0) {
                                    ForEach(0..<filteredSessions.count, id: \.self) { day in
                                        ScrollView(.vertical) {
                                            LazyVStack {
                                                ForEach(filteredSessions[day].keys, id: \.self) {
                                                    header in
                                                    LazyVStack(alignment: .leading, spacing: 0) {
                                                        ForEach(
                                                            0..<filteredSessions[day][header]!.count,
                                                            id: \.self
                                                        ) { index in
                                                            VStack(spacing: 0) {
                                                                if index != 0 { Divider() }
                                                                Button {
                                                                    self.router.forward(
                                                                        ScheduleDestinations.session(
                                                                            filteredSessions[day][
                                                                                header]![index]))
                                                                } label: {
                                                                    SessionOverView(
                                                                        session: filteredSessions[
                                                                            day][header]![index]
                                                                    )
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
                                                ContentUnavailableView {
                                                    Label("No sessions found", systemImage: "text.badge.xmark")
                                                } description: {
                                                    Text("Use fewer filters or reset all filters.")
                                                } actions: {
                                                    Button("Reset filters") {
                                                        self.filters = .init()
                                                    }
                                                    .bold()
                                                }
                                            }
                                        }
                                    }
                                }
                                .scrollTargetLayout()
                                .overlay {
                                    GeometryReader {
                                        Color.clear
                                            .preference(
                                                key: OffsetKey.self,
                                                value: $0.frame(in: .scrollView(axis: .horizontal))
                                                    .minX
                                            )
                                            .onPreferenceChange(OffsetKey.self) { value in
                                                tabProgress = max(
                                                    min(
                                                        -value
                                                            / (size.width
                                                                * CGFloat(
                                                                    filteredSessions.count - 1)),
                                                        1), 0)
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
                } else {
                    ProgressView("Loading")
                        .task {
                            await initialize()
                        }
                }
            } else {
                ContentUnavailableView {
                    Label("Something went wrong", systemImage: "exclamationmark.triangle.fill")
                } description: {
                    Text("Check your network status or try again later.")
                } actions: {
                    Button("Try Again") {
                        self.isError = false
                        Task { await initialize() }
                    }
                    .buttonStyle(.borderedProminent)
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

                    FilterMenuView(schedule: schedule, filters: $filters)
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
    private let colorGray = SIMD2<Float16>(0.55686, 0.57647)
    private let weekDayName: [LocalizedStringKey] = [
        "SUN", "MON", "TUE", "WEN", "THR", "FRI", "SAT"
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<sessions.count, id: \.self) { index in
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
                        .padding(.bottom, 11)
                        .padding(.top, 3)
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
        let factor = Float16(
            min(abs(Float32(tabProgress) - (Float32(index) / Float32(sessions.count - 1))) / (1.0 / Float32(sessions.count - 1)), 1.0))
        let color = colorGray * factor + Float16(colorScheme == .dark ? 1 : 0) * (1.0 - factor)
        return .init(red: Double(color.x), green: Double(color.x), blue: Double(color.y))
    }
}

private struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct FilterMenuView: View {
    @State var schedule: Schedule
    @Binding var filters: ScheduleFilter
    @State private var filterOption: Int?
    @State private var searchText = ""
    @Environment(\.colorScheme) var colorScheme
    let optionTitle = ["Speakers", "Types", "Rooms", "Tags"]
    var body: some View {
        Menu {
            VStack {
                Button {
                    filters.count += filters.liked ? -1 : 1
                    filters.liked.toggle()
                } label: {
                    Label("Favorite", systemImage: "heart")
                        .symbolVariant(filters.liked ? .fill : .none)
                }
                if !schedule.speakers.isEmpty {
                    Button {
                        filterOption = 0
                    } label: {
                        Label("Speakers", systemImage: "person")
                            .symbolVariant(filters.speaker.isEmpty ? .none : .fill)
                    }
                }
                if !schedule.types.isEmpty {
                    Button {
                        filterOption = 1
                    } label: {
                        Label("Types", systemImage: "signpost.right")
                            .symbolVariant(filters.type.isEmpty ? .none : .fill)
                    }
                }
                if !schedule.rooms.isEmpty {
                    Button {
                        filterOption = 2
                    } label: {
                        Label("Places", systemImage: "map")
                            .symbolVariant(filters.room.isEmpty ? .none : .fill)
                    }
                }
                if !schedule.tags.isEmpty {
                    Button {
                        filterOption = 3
                    } label: {
                        Label("Tags", systemImage: "tag")
                            .symbolVariant(filters.tag.isEmpty ? .none : .fill)
                    }
                }
                Section {
                    if filters.count != 0 {
                        Button(role: .destructive) {
                            filters = .init()
                        } label: {
                            Label("Erase All Filters", systemImage: "eraser.fill")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .symbolVariant(filters.count == 0 ? .none : .fill)
        }
        .sheet(item: $filterOption) { FilterSheetView(of: $0, with: schedule, filters: $filters) }
    }
}
struct FilterSheetView: View {
    let option: Int
    let schedule: Schedule
    @Binding var filters: ScheduleFilter
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    private let optionTitle = ["Speakers", "Types", "Rooms", "Tags"]
    init(of option: Int, with schedule: Schedule, filters: Binding<ScheduleFilter>) {
        self.option = option
        self.schedule = schedule
        self._filters = filters
    }
    var body: some View {
        NavigationStack {
            List {
                Group {
                    switch option {
                    case 0:
                        ForEach(
                            schedule.speakers.elements.filter {
                                if searchQuery.isEmpty { return true }
                                for text in searchQuery {
                                    if $0.value.localized().name.range(of: text, options: .caseInsensitive) != nil {
                                        return true
                                    }
                                }
                                return false
                            }, id: \.key
                        ) { element in
                            Button {
                                if filters.speaker.contains(element.key) {
                                    filters.count -= 1
                                    filters.speaker.remove(element.key)
                                } else {
                                    filters.count += 1
                                    filters.speaker.insert(element.key)
                                }
                            } label: {
                                Label(
                                    element.value.localized().name,
                                    systemImage: filters.speaker.contains(element.key) ? "checkmark.circle.fill" : "circle"
                                )
                            }

                        }
                    case 1:
                        ForEach(
                            schedule.types.elements.filter {
                                if searchQuery.isEmpty { return true }
                                for text in searchQuery {
                                    if $0.value.localized().name.range(of: text, options: .caseInsensitive) != nil {
                                        return true
                                    }
                                }
                                return false
                            }, id: \.key
                        ) { element in
                            Button {
                                if filters.type.contains(element.key) {
                                    filters.count -= 1
                                    filters.type.remove(element.key)
                                } else {
                                    filters.count += 1
                                    filters.type.insert(element.key)
                                }
                            } label: {
                                Label(
                                    element.value.localized().name,
                                    systemImage: filters.type.contains(element.key) ? "checkmark.circle.fill" : "circle"
                                )
                            }
                        }
                    case 2:
                        ForEach(
                            schedule.rooms.elements.filter {
                                if searchQuery.isEmpty { return true }
                                for text in searchQuery {
                                    if $0.value.localized().name.range(of: text, options: .caseInsensitive) != nil {
                                        return true
                                    }
                                }
                                return false
                            }, id: \.key
                        ) { element in
                            Button {
                                if filters.room.contains(element.key) {
                                    filters.count -= 1
                                    filters.room.remove(element.key)
                                } else {
                                    filters.count += 1
                                    filters.room.insert(element.key)
                                }
                            } label: {
                                Label(
                                    element.value.localized().name,
                                    systemImage: filters.room.contains(element.key) ? "checkmark.circle.fill" : "circle"
                                )
                            }
                        }
                    default:
                        ForEach(
                            schedule.tags.elements.filter {
                                if searchQuery.isEmpty { return true }
                                for text in searchQuery {
                                    if $0.value.localized().name.range(of: text, options: .caseInsensitive) != nil {
                                        return true
                                    }
                                }
                                return false
                            }, id: \.key
                        ) { element in
                            Button {
                                if filters.tag.contains(element.key) {
                                    filters.count -= 1
                                    filters.tag.remove(element.key)
                                } else {
                                    filters.count += 1
                                    filters.tag.insert(element.key)
                                }
                            } label: {
                                Label(
                                    element.value.localized().name,
                                    systemImage: filters.tag.contains(element.key) ? "checkmark.circle.fill" : "circle"
                                )
                            }
                        }
                    }
                }
                .foregroundStyle(colorScheme == .dark ? .white : .black)
            }
            .navigationTitle("Filter by \(optionTitle[option])")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Filter \(optionTitle[option])"
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
    private var searchQuery: [String] {
        return searchText.tirm().components(separatedBy: " ").compactMap { text in
            let text = text.tirm()
            return text.isEmpty ? nil : text
        }
    }
}
// MARK: - Helper Extensions
extension Int: @retroactive Identifiable {
    public typealias ID = Int
    public var id: Int {
        return self
    }
}
