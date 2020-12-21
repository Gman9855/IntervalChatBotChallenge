//
//  Date+Extensions.swift
//  BroChat
//
//  Created by Gershy Lev on 7/1/20.
//  Copyright © 2020 BroChat. All rights reserved.
//

import Foundation

extension Date {

    func formatRelativeString() -> String {
        let dateFormatter = DateFormatter()
        let today = Date()
        if isInSameDay(as: today) || isInYesterday {
            // today and yesterday
            // Today, 3:57 PM
            dateFormatter.doesRelativeDateFormatting = true
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .short
        } else if isInThisWeek {
            // less than a week ago
            // Friday, 4:03 PM
            dateFormatter.dateFormat = "EEEE, h:mm a"
         } else if isInThisYear {
            // more than a week ago
            // Fri, 4 Aug, 3:55
            dateFormatter.dateFormat = "E, d MMM, h:mm a"
         } else {
            // more than a year ago
            // Aug 10, 2016, 3:56
            dateFormatter.dateFormat = "MMM d, yyyy, h:mm a"
         }

        return dateFormatter.string(from: self)
    }
    
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }

    var isInThisYear:  Bool { isInSameYear(as: Date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Date()) }
    var isInThisWeek:  Bool { isInSameWeek(as: Date()) }

    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool { Calendar.current.isDateInToday(self) }
    var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }

    var isInTheFuture: Bool { self > Date() }
    var isInThePast:   Bool { self < Date() }
}
