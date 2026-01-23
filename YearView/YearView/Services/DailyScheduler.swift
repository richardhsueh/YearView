//
//  DailyScheduler.swift
//  YearView
//
//  Schedules daily wallpaper updates at midnight
//

import Foundation
import AppKit

class DailyScheduler {
    
    private var timer: Timer?
    private let updateCallback: () async -> Void
    private var lastUpdateDate: Date?
    
    init(updateCallback: @escaping () async -> Void) {
        self.updateCallback = updateCallback
    }
    
    /// Start scheduling daily updates
    func start() {
        // Record current date as last update date
        lastUpdateDate = Date()
        
        scheduleNextUpdate()
        
        // Observe system wake notifications
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemDidWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        
        // Observe system clock changes (e.g., manual date/time changes)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(systemClockDidChange),
            name: .NSSystemClockDidChange,
            object: nil
        )
        
        // Observe calendar day changes - more reliable than timer alone
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(calendarDayDidChange),
            name: .NSCalendarDayChanged,
            object: nil
        )
        
        print("✅ DailyScheduler started - monitoring day changes, system clock changes, and wake events")
    }
    
    /// Stop scheduling
    func stop() {
        timer?.invalidate()
        timer = nil
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func scheduleNextUpdate() {
        // Invalidate existing timer
        timer?.invalidate()
        timer = nil
        
        // Calculate time until next midnight
        let calendar = Calendar.current
        let now = Date()
        
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.day! += 1
        components.hour = 0
        components.minute = 0
        components.second = 1  // 1 second after midnight for safety
        
        guard let nextMidnight = calendar.date(from: components) else {
            print("Failed to calculate next midnight")
            return
        }
        
        let timeInterval = nextMidnight.timeIntervalSince(now)
        
        print("Scheduling next wallpaper update at: \(nextMidnight) (in \(Int(timeInterval)) seconds)")
        
        // Create and schedule timer with tolerance for better power efficiency
        let newTimer = Timer(timeInterval: timeInterval, repeats: false) { [weak self] _ in
            self?.performUpdate()
        }
        newTimer.tolerance = 60  // Allow up to 60 seconds tolerance for power efficiency
        
        // Add timer to common run loop modes to ensure it fires even when app is in background
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }
    
    private func performUpdate() {
        print("Performing scheduled wallpaper update at \(Date())")
        
        lastUpdateDate = Date()
        
        Task { @MainActor in
            await updateCallback()
        }
        
        // Schedule next update
        scheduleNextUpdate()
    }
    
    /// Check if the day has changed since the last update
    private func hasDayChangedSinceLastUpdate() -> Bool {
        guard let lastUpdate = lastUpdateDate else {
            return true  // No previous update, consider it changed
        }
        
        let calendar = Calendar.current
        let lastDay = calendar.startOfDay(for: lastUpdate)
        let today = calendar.startOfDay(for: Date())
        
        return today > lastDay
    }
    
    @objc private func systemDidWake() {
        print("System woke up at \(Date()), checking if update is needed")
        
        // If timer is invalid or expired, reschedule
        if timer == nil || !(timer?.isValid ?? false) {
            print("  Timer was invalid, rescheduling")
            scheduleNextUpdate()
        }
        
        // Check if the day has changed since last update
        if hasDayChangedSinceLastUpdate() {
            print("  Day has changed since last update, triggering update")
            performUpdate()
        } else {
            print("  Day has not changed, no update needed")
        }
    }
    
    @objc private func calendarDayDidChange(_ notification: Notification) {
        print("📅 Calendar day changed notification received at \(Date())")
        
        // Reschedule timer for the new day
        scheduleNextUpdate()
        
        // Perform update for the new day
        if hasDayChangedSinceLastUpdate() {
            performUpdate()
        }
    }
    
    @objc private func systemClockDidChange(_ notification: Notification) {
        print("⏰ System clock changed notification received at \(Date())")
        
        // Invalidate current timer and reschedule
        timer?.invalidate()
        timer = nil
        
        // Perform immediate update since date may have changed
        Task { @MainActor in
            print("   Executing wallpaper update due to clock change...")
            await updateCallback()
            print("   Update complete, rescheduling next update")
            // Update the last update date and schedule next update
            lastUpdateDate = Date()
            scheduleNextUpdate()
        }
    }
    
    deinit {
        stop()
    }
}
