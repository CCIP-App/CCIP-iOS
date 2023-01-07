//
//  EKEventStore+Extension.swift
//  OPass
//
//  Created by 張智堯 on 2022/6/15.
//  2023 OPass.
//

import Foundation
import EventKit

extension EKEventStore {
    func createEvent(
        title: String,
        startDate: Date,
        endDate: Date?,
        calendar: EKCalendar? = nil,
        span: EKSpan = .thisEvent,
        isAllDay: Bool = false,
        alertOffset: TimeInterval? = nil
    ) -> EKEvent {
        let event = EKEvent(eventStore: self)
        if let calendar = calendar { event.calendar = calendar }
        if let alertOffset = alertOffset { event.addAlarm(EKAlarm(relativeOffset: alertOffset)) }
        event.title = title
        event.isAllDay = isAllDay
        event.startDate = startDate
        event.endDate = endDate
        return event
    }
}
