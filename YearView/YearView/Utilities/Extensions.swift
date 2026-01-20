import Foundation
import AppKit

// MARK: - Date Extensions

extension Date {
    /// Returns a string representation of the date in a readable format
    var readableString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Check if this date is in the same day as another date
    func isSameDay(as other: Date, calendar: Calendar = .current) -> Bool {
        return calendar.isDate(self, inSameDayAs: other)
    }
}

// MARK: - Calendar Extensions

extension Calendar {
    /// Get the number of days in a specific month
    func numberOfDays(in month: Int, year: Int) -> Int? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let date = self.date(from: components),
              let range = self.range(of: .day, in: .month, for: date) else {
            return nil
        }
        
        return range.count
    }
    
    /// Get the first day of a month
    func firstDayOfMonth(month: Int, year: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        return self.date(from: components)
    }
}

// MARK: - NSColor Extensions

extension NSColor {
    /// Lighten the color by a percentage
    func lighter(by percentage: CGFloat = 0.3) -> NSColor {
        return self.adjustBrightness(by: abs(percentage))
    }
    
    /// Darken the color by a percentage
    func darker(by percentage: CGFloat = 0.3) -> NSColor {
        return self.adjustBrightness(by: -abs(percentage))
    }
    
    private func adjustBrightness(by percentage: CGFloat) -> NSColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let newBrightness = max(min(brightness + percentage, 1.0), 0.0)
        
        return NSColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
    }
}

// MARK: - String Extensions

extension String {
    /// Get size of string with given attributes
    func size(withAttributes attributes: [NSAttributedString.Key: Any]) -> CGSize {
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        return attributedString.size()
    }
}
