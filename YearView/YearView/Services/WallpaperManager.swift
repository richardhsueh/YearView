import Foundation
import AppKit

class WallpaperManager {
    
    /// Track if AppleScript has failed before to avoid repeated attempts
    private var appleScriptFailed = false
    
    /// Set wallpaper for all screens and all Spaces (virtual desktops)
    /// Uses NSWorkspace as primary method, with AppleScript as optional enhancement for multi-Space support
    func setWallpaper(imageURL: URL) throws {
        // Verify the image exists
        guard FileManager.default.fileExists(atPath: imageURL.path) else {
            throw WallpaperError.imageNotFound(path: imageURL.path)
        }
        
        // Primary method: NSWorkspace API (reliable, no special permissions needed)
        try setWallpaperWithNSWorkspace(imageURL: imageURL)
        
        // Optional: Try AppleScript for multi-Space support (only if not previously failed)
        if !appleScriptFailed {
            tryAppleScriptForAllSpaces(imageURL: imageURL)
        }
    }
    
    /// Try to set wallpaper for all Spaces using AppleScript (optional enhancement)
    /// This is best-effort and failures are silently ignored since NSWorkspace already succeeded
    private func tryAppleScriptForAllSpaces(imageURL: URL) {
        let script = """
            tell application "System Events"
                tell every desktop
                    set picture to "\(imageURL.path)"
                end tell
            end tell
            """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
            
            if error != nil {
                // AppleScript failed - likely missing Automation permissions
                // Mark as failed to avoid repeated attempts
                appleScriptFailed = true
                // Don't log error since NSWorkspace already succeeded
            }
        } else {
            appleScriptFailed = true
        }
    }
    
    /// Primary method using NSWorkspace API
    private func setWallpaperWithNSWorkspace(imageURL: URL) throws {
        let workspace = NSWorkspace.shared
        let screens = NSScreen.screens
        
        guard !screens.isEmpty else {
            throw WallpaperError.noScreensAvailable
        }
        
        // Track successes and failures to avoid inconsistent state
        var successCount = 0
        var failedScreens: [(index: Int, error: Error)] = []
        
        // Set wallpaper for each screen, continuing even if some fail
        for (index, screen) in screens.enumerated() {
            do {
                try workspace.setDesktopImageURL(imageURL, for: screen, options: [:])
                successCount += 1
            } catch {
                print("Failed to set wallpaper for screen \(index + 1): \(error)")
                failedScreens.append((index: index + 1, error: error))
            }
        }
        
        // Report results
        if failedScreens.isEmpty {
            print("✅ Wallpaper set successfully for \(successCount) screen(s)")
            return
        } else if successCount == 0 {
            throw WallpaperError.failedToSetWallpaper(underlyingError: failedScreens[0].error)
        } else {
            throw WallpaperError.partialFailure(
                successCount: successCount,
                totalCount: screens.count,
                errors: failedScreens.map { $0.error }
            )
        }
    }
    
    /// Get current wallpaper URL for main screen
    func getCurrentWallpaper() -> URL? {
        guard let mainScreen = NSScreen.main else { return nil }
        return NSWorkspace.shared.desktopImageURL(for: mainScreen)
    }
}

// MARK: - Errors

enum WallpaperError: LocalizedError {
    case noScreensAvailable
    case imageNotFound(path: String)
    case failedToSetWallpaper(underlyingError: Error)
    case partialFailure(successCount: Int, totalCount: Int, errors: [Error])
    
    var errorDescription: String? {
        switch self {
        case .noScreensAvailable:
            return "No screens available to set wallpaper"
        case .imageNotFound(let path):
            return "Wallpaper image not found: \(path)"
        case .failedToSetWallpaper(let error):
            return "Failed to set wallpaper: \(error.localizedDescription)"
        case .partialFailure(let successCount, let totalCount, _):
            return "Wallpaper set on \(successCount) of \(totalCount) screens"
        }
    }
}
