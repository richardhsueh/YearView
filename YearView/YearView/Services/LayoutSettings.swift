//
//  LayoutSettings.swift
//  YearView
//
//  Manages layout settings like font size, spacing, and font family
//

import Foundation
import Combine
import AppKit

// MARK: - Density Preset
enum DensityPreset: String, CaseIterable, Identifiable {
    case compact = "Compact"
    case normal = "Normal"
    case spacious = "Spacious"
    
    var id: String { rawValue }
    
    var baseFontSize: Double {
        switch self {
        case .compact: return 14.0
        case .normal: return 18.0
        case .spacious: return 22.0
        }
    }
    
    var horizontalMonthSpacing: Double {
        switch self {
        case .compact: return 60.0
        case .normal: return 100.0
        case .spacious: return 140.0
        }
    }
    
    var verticalMonthSpacing: Double {
        switch self {
        case .compact: return 12.0
        case .normal: return 20.0
        case .spacious: return 30.0
        }
    }
    
    var horizontalDaySpacing: Double {
        switch self {
        case .compact: return 10.0
        case .normal: return 15.0
        case .spacious: return 20.0
        }
    }
    
    var verticalDaySpacing: Double {
        switch self {
        case .compact: return 1.0
        case .normal: return 2.0
        case .spacious: return 4.0
        }
    }
}

// MARK: - Settings Snapshot (for Save/Cancel and Batch Capture)
struct LayoutSettingsSnapshot: Sendable {
    let baseFontSize: Double
    let horizontalMonthSpacing: Double
    let verticalMonthSpacing: Double
    let horizontalDaySpacing: Double
    let verticalDaySpacing: Double
    let fontFamily: String
    let markPassedDays: Bool
    let showWeekendHighlight: Bool
    let showUpdateTime: Bool
}

@MainActor
class LayoutSettings: ObservableObject {
    static let shared = LayoutSettings()
    
    private let baseFontSizeKey = "baseFontSize"
    private let horizontalMonthSpacingKey = "horizontalMonthSpacing"
    private let verticalMonthSpacingKey = "verticalMonthSpacing"
    private let horizontalDaySpacingKey = "horizontalDaySpacing"
    private let verticalDaySpacingKey = "verticalDaySpacing"
    private let fontFamilyKey = "fontFamily"
    private let markPassedDaysKey = "markPassedDays"
    private let showWeekendHighlightKey = "showWeekendHighlight"
    private let showUpdateTimeKey = "showUpdateTime"
    
    @Published var baseFontSize: Double {
        didSet {
            UserDefaults.standard.set(baseFontSize, forKey: baseFontSizeKey)
        }
    }
    
    @Published var horizontalMonthSpacing: Double {
        didSet {
            UserDefaults.standard.set(horizontalMonthSpacing, forKey: horizontalMonthSpacingKey)
        }
    }
    
    @Published var verticalMonthSpacing: Double {
        didSet {
            UserDefaults.standard.set(verticalMonthSpacing, forKey: verticalMonthSpacingKey)
        }
    }
    
    @Published var horizontalDaySpacing: Double {
        didSet {
            UserDefaults.standard.set(horizontalDaySpacing, forKey: horizontalDaySpacingKey)
        }
    }
    
    @Published var verticalDaySpacing: Double {
        didSet {
            UserDefaults.standard.set(verticalDaySpacing, forKey: verticalDaySpacingKey)
        }
    }
    
    @Published var fontFamily: String {
        didSet {
            UserDefaults.standard.set(fontFamily, forKey: fontFamilyKey)
        }
    }
    
    @Published var markPassedDays: Bool {
        didSet {
            UserDefaults.standard.set(markPassedDays, forKey: markPassedDaysKey)
        }
    }
    
    @Published var showWeekendHighlight: Bool {
        didSet {
            UserDefaults.standard.set(showWeekendHighlight, forKey: showWeekendHighlightKey)
        }
    }
    
    @Published var showUpdateTime: Bool {
        didSet {
            UserDefaults.standard.set(showUpdateTime, forKey: showUpdateTimeKey)
        }
    }
    
    private init() {
        // Load saved values or use defaults
        self.baseFontSize = UserDefaults.standard.object(forKey: baseFontSizeKey) as? Double ?? 18.0
        self.horizontalMonthSpacing = UserDefaults.standard.object(forKey: horizontalMonthSpacingKey) as? Double ?? 100.0
        self.verticalMonthSpacing = UserDefaults.standard.object(forKey: verticalMonthSpacingKey) as? Double ?? 20.0
        self.horizontalDaySpacing = UserDefaults.standard.object(forKey: horizontalDaySpacingKey) as? Double ?? 15.0
        self.verticalDaySpacing = UserDefaults.standard.object(forKey: verticalDaySpacingKey) as? Double ?? 2.0
        self.fontFamily = UserDefaults.standard.string(forKey: fontFamilyKey) ?? ".AppleSystemUIFont"
        self.markPassedDays = UserDefaults.standard.object(forKey: markPassedDaysKey) as? Bool ?? false
        self.showWeekendHighlight = UserDefaults.standard.object(forKey: showWeekendHighlightKey) as? Bool ?? false
        self.showUpdateTime = UserDefaults.standard.object(forKey: showUpdateTimeKey) as? Bool ?? false
    }
    
    func reset() {
        applyPreset(.normal)
        fontFamily = ".AppleSystemUIFont"
        markPassedDays = false
        showWeekendHighlight = false
        showUpdateTime = false
    }
    
    // MARK: - Preset Support
    
    func applyPreset(_ preset: DensityPreset) {
        baseFontSize = preset.baseFontSize
        horizontalMonthSpacing = preset.horizontalMonthSpacing
        verticalMonthSpacing = preset.verticalMonthSpacing
        horizontalDaySpacing = preset.horizontalDaySpacing
        verticalDaySpacing = preset.verticalDaySpacing
    }
    
    var currentPreset: DensityPreset? {
        for preset in DensityPreset.allCases {
            if baseFontSize == preset.baseFontSize &&
               horizontalMonthSpacing == preset.horizontalMonthSpacing &&
               verticalMonthSpacing == preset.verticalMonthSpacing &&
               horizontalDaySpacing == preset.horizontalDaySpacing &&
               verticalDaySpacing == preset.verticalDaySpacing {
                return preset
            }
        }
        return nil // Custom settings
    }
    
    // MARK: - Snapshot Support (for Save/Cancel)
    
    func createSnapshot() -> LayoutSettingsSnapshot {
        return LayoutSettingsSnapshot(
            baseFontSize: baseFontSize,
            horizontalMonthSpacing: horizontalMonthSpacing,
            verticalMonthSpacing: verticalMonthSpacing,
            horizontalDaySpacing: horizontalDaySpacing,
            verticalDaySpacing: verticalDaySpacing,
            fontFamily: fontFamily,
            markPassedDays: markPassedDays,
            showWeekendHighlight: showWeekendHighlight,
            showUpdateTime: showUpdateTime
        )
    }
    
    func restore(from snapshot: LayoutSettingsSnapshot) {
        baseFontSize = snapshot.baseFontSize
        horizontalMonthSpacing = snapshot.horizontalMonthSpacing
        verticalMonthSpacing = snapshot.verticalMonthSpacing
        horizontalDaySpacing = snapshot.horizontalDaySpacing
        verticalDaySpacing = snapshot.verticalDaySpacing
        fontFamily = snapshot.fontFamily
        markPassedDays = snapshot.markPassedDays
        showWeekendHighlight = snapshot.showWeekendHighlight
        showUpdateTime = snapshot.showUpdateTime
    }
    
    // MARK: - Font Helpers
    
    /// Cached list of available font families (computed once on first access)
    /// Using nonisolated(unsafe) because font families don't change during app lifecycle
    /// and NSFontManager.shared.availableFontFamilies is thread-safe for reading
    private nonisolated(unsafe) static let _cachedFontFamilies: [String] = {
        return NSFontManager.shared.availableFontFamilies.sorted()
    }()
    
    static var availableFontFamilies: [String] {
        return _cachedFontFamilies
    }
}
