import Cocoa
import CoreGraphics

/// Renders calendar wallpaper images using Core Graphics
class WallpaperRenderer {
    
    // MARK: - Properties
    
    private let themeManager: ThemeManager
    private let layoutSettings: LayoutSettings
    
    // MARK: - Initialization
    
    init(themeManager: ThemeManager, layoutSettings: LayoutSettings) {
        self.themeManager = themeManager
        self.layoutSettings = layoutSettings
    }
    
    // MARK: - Layout Constants
    
    private struct LayoutMetrics {
        // Font size multipliers relative to baseFontSize
        static let headerFontMultiplier: CGFloat = 1.5
        static let weekdayFontMultiplier: CGFloat = 1.2
        static let dayFontMultiplier: CGFloat = 1.0
        
        // Spacing multipliers relative to baseFontSize
        static let dayRowHeightMultiplier: CGFloat = 1.8
        static let weekdayRowHeightMultiplier: CGFloat = 1.5
        static let headerHeightMultiplier: CGFloat = 1.3
        static let dayCellWidthMultiplier: CGFloat = 2.2
        static let headerGap: CGFloat = 8
        static let weekdayDayGap: CGFloat = 3
        
        // Grid dimensions
        static let columns = 4
        static let rows = 3
        static let daysPerWeek = 7
        static let maxWeeksPerMonth = 6
    }
    
    // MARK: - Public Methods
    
    /// Render a wallpaper image for the given year calendar
    /// - Parameter yearCalendar: The calendar data to render
    /// - Returns: URL to the generated wallpaper image
    func renderWallpaper(yearCalendar: YearCalendar) async throws -> URL {
        // Capture main-actor values before entering detached task
        let baseFontSize = await layoutSettings.baseFontSize
        let horizontalMonthSpacing = await layoutSettings.horizontalMonthSpacing
        let verticalMonthSpacing = await layoutSettings.verticalMonthSpacing
        let horizontalDaySpacing = await layoutSettings.horizontalDaySpacing
        let verticalDaySpacing = await layoutSettings.verticalDaySpacing
        let fontFamily = await layoutSettings.fontFamily
        let markPassedDays = await layoutSettings.markPassedDays
        let theme = themeManager.currentTheme
        
        print("📐 Rendering wallpaper with fontSize: \(baseFontSize), hMonthSpacing: \(horizontalMonthSpacing), vMonthSpacing: \(verticalMonthSpacing), hDaySpacing: \(horizontalDaySpacing), vDaySpacing: \(verticalDaySpacing), Font=\(fontFamily)")
        
        return try await Task.detached(priority: .userInitiated) {
            let screenSize = self.getScreenSize()
            let image = self.createWallpaperImage(
                yearCalendar: yearCalendar,
                size: screenSize,
                baseFontSize: CGFloat(baseFontSize),
                horizontalMonthSpacing: CGFloat(horizontalMonthSpacing),
                verticalMonthSpacing: CGFloat(verticalMonthSpacing),
                horizontalDaySpacing: CGFloat(horizontalDaySpacing),
                verticalDaySpacing: CGFloat(verticalDaySpacing),
                fontFamily: fontFamily,
                markPassedDays: markPassedDays,
                theme: theme
            )
            
            // Save to temporary location with unique filename to force macOS to recognize changes
            let tempDirectory = FileManager.default.temporaryDirectory
            
            // Clean up old wallpaper files to prevent accumulation
            self.cleanupOldWallpapers(in: tempDirectory)
            
            // Include timestamp to ensure unique filename and force macOS to refresh
            let timestamp = Int(Date().timeIntervalSince1970)
            let fileName = "calendar_wallpaper_\(yearCalendar.year)_\(theme.identifier)_fs\(Int(baseFontSize))_hms\(Int(horizontalMonthSpacing))_vms\(Int(verticalMonthSpacing))_hds\(Int(horizontalDaySpacing))_vds\(Int(verticalDaySpacing))_\(fontFamily.replacingOccurrences(of: " ", with: ""))_\(timestamp).png"
            let fileURL = tempDirectory.appendingPathComponent(fileName)
            
            guard let pngData = image.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: pngData),
                  let pngImageData = bitmap.representation(using: .png, properties: [:]) else {
                throw RendererError.imageGenerationFailed
            }
            
            try pngImageData.write(to: fileURL)
            return fileURL
        }.value
    }
    
    // MARK: - Private Methods
    
    /// Clean up old calendar wallpaper files from the temporary directory
    private func cleanupOldWallpapers(in directory: URL) {
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.creationDateKey],
                options: [.skipsHiddenFiles]
            )
            
            // Find old calendar wallpaper files
            let wallpaperFiles = files.filter { $0.lastPathComponent.starts(with: "calendar_wallpaper_") }
            
            // Keep only the 2 most recent files, delete the rest
            let sortedFiles = wallpaperFiles.sorted { (url1, url2) -> Bool in
                let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                return date1 > date2
            }
            
            for file in sortedFiles.dropFirst(2) {
                try? fileManager.removeItem(at: file)
                print("🗑️ Cleaned up old wallpaper: \(file.lastPathComponent)")
            }
        } catch {
            print("⚠️ Failed to clean up old wallpapers: \(error)")
        }
    }
    
    /// Helper to create a font with the specified family, size, and weight
    private nonisolated func createFont(family: String, size: CGFloat, weight: NSFont.Weight) -> NSFont {
        // Handle system font specially
        if family == ".AppleSystemUIFont" || family.isEmpty {
            return NSFont.systemFont(ofSize: size, weight: weight)
        }
        
        // Try to find the font with the appropriate weight
        // NSFontManager is thread-safe despite being MainActor-isolated
        nonisolated(unsafe) let fontManager = NSFontManager.shared
        
        // Get available members of the font family
        guard let members = fontManager.availableMembers(ofFontFamily: family),
              !members.isEmpty else {
            // Fallback to system font if family not found
            return NSFont.systemFont(ofSize: size, weight: weight)
        }
        
        // Map NSFont.Weight to font traits we're looking for
        let targetWeight: Int
        switch weight {
        case .ultraLight: targetWeight = 2
        case .thin: targetWeight = 3
        case .light: targetWeight = 4
        case .regular: targetWeight = 5
        case .medium: targetWeight = 6
        case .semibold: targetWeight = 8
        case .bold: targetWeight = 9
        case .heavy: targetWeight = 10
        case .black: targetWeight = 11
        default: targetWeight = 5
        }
        
        // Find the best matching font member
        var bestMatch: (name: String, weightDiff: Int)? = nil
        for member in members {
            guard let fontName = member[0] as? String,
                  let fontWeight = member[1] as? Int else { continue }
            
            let weightDiff = abs(fontWeight - targetWeight)
            if bestMatch == nil || weightDiff < bestMatch!.weightDiff {
                bestMatch = (fontName, weightDiff)
            }
        }
        
        // Create font with best match or fallback
        if let bestMatch = bestMatch,
           let font = NSFont(name: bestMatch.name, size: size) {
            return font
        }
        
        // Final fallback: try the family name directly
        return NSFont(name: family, size: size) ?? NSFont.systemFont(ofSize: size, weight: weight)
    }
    
    private nonisolated func getScreenSize() -> CGSize {
        // NSScreen is thread-safe despite being MainActor-isolated
        nonisolated(unsafe) let mainScreen = NSScreen.main
        if let screen = mainScreen {
            let frame = screen.frame
            // Account for Retina displays
            let scale = screen.backingScaleFactor
            return CGSize(width: frame.width * scale, height: frame.height * scale)
        }
        // Fallback to common resolution
        return CGSize(width: 2560, height: 1440)
    }
    
    /// Calculate the dimensions of a single month cell based on font size and day spacing
    private func calculateMonthDimensions(baseFontSize: CGFloat, horizontalDaySpacing: CGFloat, verticalDaySpacing: CGFloat) -> (width: CGFloat, height: CGFloat) {
        let headerFontSize = baseFontSize * LayoutMetrics.headerFontMultiplier
        let weekdayFontSize = baseFontSize * LayoutMetrics.weekdayFontMultiplier
        
        // Calculate height components
        let headerHeight = headerFontSize * LayoutMetrics.headerHeightMultiplier
        let weekdayRowHeight = weekdayFontSize * LayoutMetrics.weekdayRowHeightMultiplier
        let dayRowHeight = baseFontSize * LayoutMetrics.dayRowHeightMultiplier
        
        // Total month height: header + gap + weekday row + gap + 6 day rows with vertical spacing
        let dayGridHeight = (dayRowHeight * CGFloat(LayoutMetrics.maxWeeksPerMonth)) + (verticalDaySpacing * CGFloat(LayoutMetrics.maxWeeksPerMonth - 1))
        let monthHeight = headerHeight + LayoutMetrics.headerGap + weekdayRowHeight + LayoutMetrics.weekdayDayGap + dayGridHeight
        
        // Calculate width: 7 day cells with horizontal spacing
        let dayCellWidth = baseFontSize * LayoutMetrics.dayCellWidthMultiplier
        let monthWidth = (dayCellWidth * CGFloat(LayoutMetrics.daysPerWeek)) + (horizontalDaySpacing * CGFloat(LayoutMetrics.daysPerWeek - 1))
        
        return (width: monthWidth, height: monthHeight)
    }
    
    private func createWallpaperImage(yearCalendar: YearCalendar, size: CGSize, baseFontSize: CGFloat, horizontalMonthSpacing: CGFloat, verticalMonthSpacing: CGFloat, horizontalDaySpacing: CGFloat, verticalDaySpacing: CGFloat, fontFamily: String, markPassedDays: Bool, theme: Theme) -> NSImage {
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Draw background
        theme.background.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        // Calculate month dimensions from font size and day spacing
        let monthDimensions = calculateMonthDimensions(baseFontSize: baseFontSize, horizontalDaySpacing: horizontalDaySpacing, verticalDaySpacing: verticalDaySpacing)
        let monthWidth = monthDimensions.width
        let monthHeight = monthDimensions.height
        
        // Calculate total grid size (4 columns × 3 rows)
        let columns = LayoutMetrics.columns
        let rows = LayoutMetrics.rows
        
        let gridWidth = (monthWidth * CGFloat(columns)) + (horizontalMonthSpacing * CGFloat(columns - 1))
        let gridHeight = (monthHeight * CGFloat(rows)) + (verticalMonthSpacing * CGFloat(rows - 1))
        
        // Center grid on screen
        let offsetX = (size.width - gridWidth) / 2
        let offsetY = (size.height - gridHeight) / 2
        
        // Draw each month
        for row in 0..<rows {
            for col in 0..<columns {
                let monthIndex = row * columns + col
                guard monthIndex < yearCalendar.months.count else { continue }
                let month = yearCalendar.months[monthIndex]
                
                let x = offsetX + (monthWidth + horizontalMonthSpacing) * CGFloat(col)
                // Invert row order so January is at top-left
                let y = offsetY + gridHeight - (monthHeight + verticalMonthSpacing) * CGFloat(row) - monthHeight
                
                let monthRect = CGRect(x: x, y: y, width: monthWidth, height: monthHeight)
                drawMonth(month: month, in: monthRect, baseFontSize: baseFontSize, horizontalDaySpacing: horizontalDaySpacing, verticalDaySpacing: verticalDaySpacing, fontFamily: fontFamily, markPassedDays: markPassedDays, theme: theme)
            }
        }
        
        // Draw year watermark in center
        let watermarkText = "\(yearCalendar.year)"
        let watermarkSize = min(size.width, size.height) * 0.5
        let watermarkFont = createFont(family: fontFamily, size: watermarkSize, weight: .black)
        
        // Create accent color with 10% opacity
        let watermarkColor = theme.accent.withAlphaComponent(0.1)
        let watermarkAttributes: [NSAttributedString.Key: Any] = [
            .font: watermarkFont,
            .foregroundColor: watermarkColor
        ]
        
        let textSize = watermarkText.size(withAttributes: watermarkAttributes)
        let watermarkX = (size.width - textSize.width) / 2
        let watermarkY = (size.height - textSize.height) / 2
        
        watermarkText.draw(at: CGPoint(x: watermarkX, y: watermarkY), withAttributes: watermarkAttributes)
        
        image.unlockFocus()
        
        return image
    }
    
    private func drawMonth(month: MonthCalendar, in rect: CGRect, baseFontSize: CGFloat, horizontalDaySpacing: CGFloat, verticalDaySpacing: CGFloat, fontFamily: String, markPassedDays: Bool, theme: Theme) {
        let context = NSGraphicsContext.current?.cgContext
        let today = Date()
        
        // Calculate font sizes from baseFontSize
        let headerFontSize = baseFontSize * LayoutMetrics.headerFontMultiplier
        let weekdayFontSize = baseFontSize * LayoutMetrics.weekdayFontMultiplier
        let dayFontSize = baseFontSize * LayoutMetrics.dayFontMultiplier
        
        // Calculate layout dimensions
        let dayCellWidth = baseFontSize * LayoutMetrics.dayCellWidthMultiplier
        let dayRowHeight = baseFontSize * LayoutMetrics.dayRowHeightMultiplier
        let weekdayRowHeight = weekdayFontSize * LayoutMetrics.weekdayRowHeightMultiplier
        
        // Draw month name header
        let headerFont = createFont(family: fontFamily, size: headerFontSize, weight: .semibold)
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: theme.foreground
        ]
        
        let headerText = "\(month.name)"
        let headerSize = headerText.size(withAttributes: headerAttributes)
        let headerY = rect.maxY - headerSize.height
        
        // Prepare weekday font and attributes
        let weekdayFont = createFont(family: fontFamily, size: weekdayFontSize, weight: .heavy)
        let weekdayAttributes: [NSAttributedString.Key: Any] = [
            .font: weekdayFont,
            .foregroundColor: theme.subtext
        ]
        
        // Align header with the first weekday label
        let firstWeekdayLabel = "S"
        let firstLabelSize = firstWeekdayLabel.size(withAttributes: weekdayAttributes)
        let firstLabelX = rect.minX + (dayCellWidth - firstLabelSize.width) / 2
        
        let headerX = firstLabelX
        headerText.draw(at: CGPoint(x: headerX, y: headerY), withAttributes: headerAttributes)
        
        // Calculate calendar grid area
        let calendarTop = headerY - LayoutMetrics.headerGap
        
        // Draw weekday labels
        let weekdayLabels = ["S", "M", "T", "W", "T", "F", "S"]
        let weekdayY = calendarTop - weekdayRowHeight
        
        for (index, label) in weekdayLabels.enumerated() {
            let labelSize = label.size(withAttributes: weekdayAttributes)
            let x = rect.minX + (dayCellWidth + horizontalDaySpacing) * CGFloat(index) + (dayCellWidth - labelSize.width) / 2
            let y = weekdayY + (weekdayRowHeight - labelSize.height) / 2
            label.draw(at: CGPoint(x: x, y: y), withAttributes: weekdayAttributes)
        }
        
        // Draw days grid
        let gridTop = weekdayY - LayoutMetrics.weekdayDayGap
        
        let dayFont = createFont(family: fontFamily, size: dayFontSize, weight: .regular)
        let todayFont = createFont(family: fontFamily, size: dayFontSize, weight: .semibold)
        
        // Calculate starting position based on first weekday
        // Sunday start (1 = Sunday, 2 = Monday, etc.)
        let startColumn = month.firstWeekday - 1
        
        var currentColumn = startColumn
        var currentRow = 0
        
        for day in month.days {
            let cellX = rect.minX + (dayCellWidth + horizontalDaySpacing) * CGFloat(currentColumn)
            let cellY = gridTop - (dayRowHeight + verticalDaySpacing) * CGFloat(currentRow) - dayRowHeight
            let cellRect = CGRect(x: cellX, y: cellY, width: dayCellWidth, height: dayRowHeight)
            
            // Draw today highlight circle
            if day.isToday {
                context?.setFillColor(theme.accent.cgColor)
                let circleSize = min(dayCellWidth, dayRowHeight) * 0.85
                let circleRect = CGRect(
                    x: cellRect.midX - circleSize / 2,
                    y: cellRect.midY - circleSize / 2,
                    width: circleSize,
                    height: circleSize
                )
                context?.fillEllipse(in: circleRect)
            }
            
            // Draw day number
            let dayText = "\(day.day)"
            
            // Determine text color: today uses background, weekend uses accent, others use foreground
            let textColor: NSColor
            if day.isToday {
                textColor = theme.background
            } else if day.isWeekend {
                textColor = theme.accent
            } else {
                textColor = theme.foreground
            }
            
            let dayAttributes: [NSAttributedString.Key: Any] = [
                .font: day.isToday ? todayFont : dayFont,
                .foregroundColor: textColor
            ]
            
            let daySize = dayText.size(withAttributes: dayAttributes)
            let dayX = cellRect.midX - daySize.width / 2
            let dayY = cellRect.midY - daySize.height / 2
            
            dayText.draw(at: CGPoint(x: dayX, y: dayY), withAttributes: dayAttributes)
            
            // Draw diagonal line on passed days
            if markPassedDays && day.date < today && !day.isToday {
                context?.saveGState()
                
                let strikethroughColor = theme.strikethrough ?? theme.accent
                context?.setStrokeColor(strikethroughColor.cgColor)
                context?.setLineWidth(2.0)
                context?.setLineCap(.round)
                
                let lineInset: CGFloat = dayCellWidth * 0.25
                let lineRect = cellRect.insetBy(dx: lineInset, dy: lineInset)
                
                // Draw diagonal line from top-right to bottom-left
                context?.move(to: CGPoint(x: lineRect.maxX, y: lineRect.maxY))
                context?.addLine(to: CGPoint(x: lineRect.minX, y: lineRect.minY))
                context?.strokePath()
                
                context?.restoreGState()
            }
            
            // Move to next cell
            currentColumn += 1
            if currentColumn >= LayoutMetrics.daysPerWeek {
                currentColumn = 0
                currentRow += 1
            }
        }
    }
}

// MARK: - Errors

enum RendererError: LocalizedError {
    case imageGenerationFailed
    
    var errorDescription: String? {
        switch self {
        case .imageGenerationFailed:
            return "Failed to generate wallpaper image"
        }
    }
}
