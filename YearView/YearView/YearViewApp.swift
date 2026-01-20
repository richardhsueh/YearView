import SwiftUI
import UserNotifications

@main
struct YearViewApp: App {
    @StateObject private var wallpaperService = WallpaperService()
    @StateObject private var themeStore = ThemeStore()
    
    init() {
        requestNotificationPermissions()
    }
    
    var body: some Scene {
        MenuBarExtra("Calendar", systemImage: "calendar") {
            MenuContentView()
                .environmentObject(wallpaperService)
                .environmentObject(themeStore)
                .task {
                    // Ensure wallpaper updates on first launch
                    await wallpaperService.updateWallpaper()
                }
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
}
