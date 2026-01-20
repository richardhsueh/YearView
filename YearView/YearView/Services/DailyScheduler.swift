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
    
    init(updateCallback: @escaping () async -> Void) {
        self.updateCallback = updateCallback
    }
    
    /// Start scheduling daily updates
    func start() {
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
        
        print("✅ DailyScheduler started - monitoring system clock changes and wake events")
    }
    
    /// Stop scheduling
    func stop() {
        timer?.invalidate()
        timer = nil
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func scheduleNextUpdate() {
        // Calculate time until next midnight
        let calendar = Calendar.current
        let now = Date()
        
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.day! += 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        guard let nextMidnight = calendar.date(from: components) else {
            print("Failed to calculate next midnight")
            return
        }
        
        let timeInterval = nextMidnight.timeIntervalSince(now)
        
        print("Scheduling next wallpaper update at: \(nextMidnight)")
        
        // Schedule timer
        timer = Timer.scheduledTimer(
            withTimeInterval: timeInterval,
            repeats: false
        ) { [weak self] _ in
            self?.performUpdate()
        }
    }
    
    private func performUpdate() {
        print("Performing scheduled wallpaper update")
        
        Task { @MainActor in
            await updateCallback()
        }
        
        // Schedule next update
        scheduleNextUpdate()
    }
    
    @objc private func systemDidWake() {
        print("System woke up, checking if update is needed")
        
        // Check if we missed an update while sleeping
        let calendar = Calendar.current
        let now = Date()
        
        // If timer is invalid or expired, reschedule
        if timer == nil || !(timer?.isValid ?? false) {
            scheduleNextUpdate()
        }
        
        // Check if we're past midnight and need to update
        let hour = calendar.component(.hour, from: now)
        if hour >= 0 && hour < 1 {
            performUpdate()
        }
    }
    
    @objc private func systemClockDidChange(_ notification: Notification) {
        print("⏰⏰⏰ SYSTEM CLOCK CHANGED NOTIFICATION RECEIVED ⏰⏰⏰")
        print("   Notification object: \(String(describing: notification.object))")
        print("   Current date: \(Date())")
        
        // Invalidate current timer and reschedule
        timer?.invalidate()
        timer = nil
        
        // Perform immediate update since date may have changed
        Task { @MainActor in
            print("   Executing wallpaper update on main actor...")
            await updateCallback()
            print("   Update complete, rescheduling next update")
            // Schedule next update after the update completes
            scheduleNextUpdate()
        }
    }
    
    deinit {
        stop()
    }
}
