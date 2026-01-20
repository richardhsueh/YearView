//
//  CalendarGenerator.swift
//  YearView
//
//  Generates calendar data for rendering
//

import Foundation

/// Generates calendar data for rendering
class CalendarGenerator {
    private let calendar: Calendar
    
    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }
    
    /// Generate calendar data for the current year
    func generateCurrentYearData() -> YearCalendar {
        let currentYear = calendar.component(.year, from: Date())
        return generateYearData(for: currentYear)
    }
    
    /// Generate calendar data for a specific year
    /// - Parameter year: The year to generate calendar data for
    /// - Returns: A YearCalendar containing all months and days
    func generateYearData(for year: Int) -> YearCalendar {
        return calendar.generateYearData(for: year)
    }
    
    /// Check if a given date is a weekend
    /// - Parameter date: The date to check
    /// - Returns: True if the date is Saturday or Sunday
    func isWeekend(date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7 // Sunday or Saturday
    }
    
    /// Check if a given date is today
    /// - Parameter date: The date to check
    /// - Returns: True if the date is today
    func isToday(date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }
    
    /// Get the current date
    func currentDate() -> Date {
        return Date()
    }
    
    /// Get the current year
    func currentYear() -> Int {
        return calendar.component(.year, from: Date())
    }
}
