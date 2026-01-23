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
        MenuBarExtra("Calendar", image: "MenuBarIcon") {
            MenuContentView()
                .environmentObject(wallpaperService)
                .environmentObject(themeStore)
            // Note: Initial update is handled by WallpaperService.init()
            // Removed duplicate .task to avoid redundant wallpaper generation
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
