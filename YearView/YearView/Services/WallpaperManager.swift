import Foundation
import AppKit

class WallpaperManager {
    
    /// Set wallpaper for all screens and all Spaces (virtual desktops)
    /// Uses AppleScript to ensure wallpaper is set across all Spaces
    func setWallpaper(imageURL: URL) throws {
        // Verify the image exists
        guard FileManager.default.fileExists(atPath: imageURL.path) else {
            throw WallpaperError.imageNotFound(path: imageURL.path)
        }
        
        // Use AppleScript to set wallpaper for all desktops (all Spaces on all screens)
        // This is the most reliable way to sync across all virtual desktops
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
            
            if let error = error {
                let errorMessage = error[NSAppleScript.errorMessage] as? String ?? "Unknown AppleScript error"
                print("AppleScript error: \(errorMessage)")
                
                // Fall back to NSWorkspace API for current Space only
                print("Falling back to NSWorkspace API...")
                try setWallpaperWithNSWorkspace(imageURL: imageURL)
            } else {
                print("Successfully set wallpaper for all desktops via AppleScript")
            }
        } else {
            // AppleScript creation failed, fall back to NSWorkspace
            print("Failed to create AppleScript, falling back to NSWorkspace API...")
            try setWallpaperWithNSWorkspace(imageURL: imageURL)
        }
    }
    
    /// Fallback method using NSWorkspace API (only affects current Space)
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
