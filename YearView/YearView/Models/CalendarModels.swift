//
//  CalendarModels.swift
//  YearView
//
//  Data models for calendar generation
//

import Foundation

/// Represents a full year's calendar data
struct YearCalendar: Identifiable {
    var id: Int { year }
    let year: Int
    let months: [MonthCalendar]
}

/// Represents a single month's calendar data
struct MonthCalendar: Identifiable {
    var id: String { "\(year)-\(month)" }
    let name: String
    let year: Int
    let month: Int
    let days: [DayData]
    let firstWeekday: Int  // 1 = Sunday, 2 = Monday, etc.
}

/// Represents a single day's data
struct DayData {
    let day: Int
    let date: Date
    let isWeekend: Bool
    let isToday: Bool
}

// MARK: - Calendar Generator Extension

extension Calendar {
    /// Generate full year calendar data
    func generateYearData(for year: Int) -> YearCalendar {
        var months: [MonthCalendar] = []
        
        // Cache today's date once for all month generation
        let today = Date()
        
        for month in 1...12 {
            if let monthData = generateMonthData(year: year, month: month, today: today) {
                months.append(monthData)
            }
        }
        
        return YearCalendar(year: year, months: months)
    }
    
    /// Generate single month calendar data
    /// - Parameters:
    ///   - year: The year
    ///   - month: The month (1-12)
    ///   - today: Cached today's date to avoid repeated Date() calls
    func generateMonthData(year: Int, month: Int, today: Date? = nil) -> MonthCalendar? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let firstDay = date(from: components),
              let range = range(of: .day, in: .month, for: firstDay) else {
            return nil
        }
        
        let monthName = monthSymbols[month - 1]
        let firstWeekday = component(.weekday, from: firstDay)
        
        // Use provided today or create new (fallback)
        let todayDate = today ?? Date()
        
        // Pre-reserve capacity for days array
        var days: [DayData] = []
        days.reserveCapacity(range.count)
        
        for day in 1...range.count {
            var dayComponents = DateComponents()
            dayComponents.year = year
            dayComponents.month = month
            dayComponents.day = day
            
            guard let dayDate = date(from: dayComponents) else { continue }
            
            let weekday = component(.weekday, from: dayDate)
            let isWeekend = (weekday == 1 || weekday == 7) // Sunday or Saturday
            let isToday = isDate(dayDate, inSameDayAs: todayDate)
            
            days.append(DayData(
                day: day,
                date: dayDate,
                isWeekend: isWeekend,
                isToday: isToday
            ))
        }
        
        return MonthCalendar(
            name: monthName,
            year: year,
            month: month,
            days: days,
            firstWeekday: firstWeekday
        )
    }
}
