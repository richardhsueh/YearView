//
//  Theme.swift
//  YearView
//
//  Theme model for calendar wallpaper styling
//

import Foundation
import AppKit

/// Represents a color theme for the calendar wallpaper
struct Theme: Identifiable, Hashable {
    let id: String
    let name: String
    let identifier: String
    
    // Core colors
    let background: NSColor
    let foreground: NSColor      // Main text color
    let subtext: NSColor         // Secondary text (weekday labels)
    let accent: NSColor          // Current day highlight
    let weekend: NSColor         // Weekend background
    
    // Optional colors
    let strikethrough: NSColor?  // For marking passed days
    let muted: NSColor?          // For subtle elements
    
    init(
        name: String,
        identifier: String,
        background: String,
        foreground: String,
        subtext: String,
        accent: String,
        weekend: String,
        strikethrough: String? = nil,
        muted: String? = nil
    ) {
        self.id = identifier
        self.name = name
        self.identifier = identifier
        self.background = NSColor(hex: background)
        self.foreground = NSColor(hex: foreground)
        self.subtext = NSColor(hex: subtext)
        self.accent = NSColor(hex: accent)
        self.weekend = NSColor(hex: weekend)
        self.strikethrough = strikethrough != nil ? NSColor(hex: strikethrough!) : nil
        self.muted = muted != nil ? NSColor(hex: muted!) : nil
    }
    
    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Theme, rhs: Theme) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - NSColor Hex Extension
extension NSColor {
    /// Initialize NSColor from hex string
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
    
    /// Convert NSColor to hex string
    func toHexString() -> String {
        guard let rgbColor = usingColorSpace(.deviceRGB) else {
            return "#000000"
        }
        let red = Int(round(rgbColor.redComponent * 0xFF))
        let green = Int(round(rgbColor.greenComponent * 0xFF))
        let blue = Int(round(rgbColor.blueComponent * 0xFF))
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}
