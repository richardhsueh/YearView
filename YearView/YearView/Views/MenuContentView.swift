import SwiftUI

struct MenuContentView: View {
    @EnvironmentObject var wallpaperService: WallpaperService
    @EnvironmentObject var themeStore: ThemeStore
    @StateObject private var settingsWindowManager = SettingsWindowManager()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            Text("Calendar Wallpaper")
                .font(.headline)
            
            // Status
            if let lastUpdate = wallpaperService.lastUpdateTime {
                Text("Updated \(lastUpdate, style: .relative)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Not yet updated")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Show error if any
            if let error = wallpaperService.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .lineLimit(2)
            }
            
            // Show updating status
            if wallpaperService.isUpdating {
                HStack {
                    ProgressView()
                        .scaleEffect(0.6)
                        .frame(width: 12, height: 12)
                    Text("Updating...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Theme selector
            ThemePickerView()
            
            Divider()
            
            // Settings button
            Button("Settings...") {
                settingsWindowManager.showSettings(wallpaperService: wallpaperService, themeStore: themeStore)
            }
            .keyboardShortcut(",")
            
            // Manual refresh button
            Button("Refresh Wallpaper") {
                Task {
                    await wallpaperService.updateWallpaper()
                }
            }
            .keyboardShortcut("r")
            .disabled(wallpaperService.isUpdating)
            
            Divider()
            
            // Quit
            Button("Quit") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding()
        .frame(width: 250)
        // Note: Initial update is handled by WallpaperService.init()
        // No .task needed here to avoid duplicate updates
    }
}
