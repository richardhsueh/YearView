import Foundation
import AppKit

class WallpaperManager {
    
    /// Set wallpaper for all screens
    func setWallpaper(imageURL: URL) throws {
        let workspace = NSWorkspace.shared
        
        // Get all screens
        let screens = NSScreen.screens
        
        guard !screens.isEmpty else {
            throw WallpaperError.noScreensAvailable
        }
        
        // Set wallpaper for each screen
        for screen in screens {
            do {
                try workspace.setDesktopImageURL(imageURL, for: screen, options: [:])
            } catch {
                print("Failed to set wallpaper for screen: \(error)")
                throw WallpaperError.failedToSetWallpaper(underlyingError: error)
            }
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
    case failedToSetWallpaper(underlyingError: Error)
    
    var errorDescription: String? {
        switch self {
        case .noScreensAvailable:
            return "No screens available to set wallpaper"
        case .failedToSetWallpaper(let error):
            return "Failed to set wallpaper: \(error.localizedDescription)"
        }
    }
}
