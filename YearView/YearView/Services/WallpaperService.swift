import SwiftUI
import UserNotifications
import Combine

@MainActor
class WallpaperService: ObservableObject {
    @Published var lastUpdateTime: Date?
    @Published var isUpdating = false
    @Published var errorMessage: String?
    
    private let calendarGenerator: CalendarGenerator
    private let wallpaperRenderer: WallpaperRenderer
    private let wallpaperManager: WallpaperManager
    private var scheduler: DailyScheduler?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.calendarGenerator = CalendarGenerator()
        self.wallpaperRenderer = WallpaperRenderer(themeManager: .shared, layoutSettings: .shared)
        self.wallpaperManager = WallpaperManager()
        self.scheduler = nil
        
        // Create scheduler after self is fully initialized
        self.scheduler = DailyScheduler { [weak self] in
            await self?.updateWallpaper()
        }
        
        // Start scheduler
        scheduler?.start()
        
        // Listen for theme changes
        NotificationCenter.default.publisher(for: .themeDidChange)
            .sink { [weak self] _ in
                Task {
                    await self?.updateWallpaper()
                }
            }
            .store(in: &cancellables)
        
        // Initial update
        Task {
            await updateWallpaper()
        }
    }
    
    func updateWallpaper() async {
        guard !isUpdating else { return }
        isUpdating = true
        errorMessage = nil
        
        print("Starting wallpaper update...")
        
        do {
            let yearCalendar = calendarGenerator.generateCurrentYearData()
            print("Generated calendar data for year \(yearCalendar.year)")
            
            let imageURL = try await wallpaperRenderer.renderWallpaper(yearCalendar: yearCalendar)
            print("Rendered wallpaper image at: \(imageURL.path)")
            
            try wallpaperManager.setWallpaper(imageURL: imageURL)
            print("Successfully set desktop wallpaper")
            
            lastUpdateTime = Date()
            
            // Show notification
            await showNotification(title: "Wallpaper Updated", message: "Calendar for \(yearCalendar.year)")
        } catch {
            print("Error updating wallpaper: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            await showErrorNotification(error: error)
        }
        
        isUpdating = false
    }
    
    private func showNotification(title: String, message: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    private func showErrorNotification(error: Error) async {
        let content = UNMutableNotificationContent()
        content.title = "Wallpaper Update Failed"
        content.body = error.localizedDescription
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    deinit {
        scheduler?.stop()
    }
}
