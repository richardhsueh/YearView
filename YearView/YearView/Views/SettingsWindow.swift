//
//  SettingsWindow.swift
//  YearView
//
//  Settings window for layout configuration
//

import SwiftUI

struct SettingsWindow: View {
    @StateObject private var layoutSettings = LayoutSettings.shared
    @EnvironmentObject var wallpaperService: WallpaperService
    @EnvironmentObject var themeStore: ThemeStore
    @Environment(\.dismiss) var dismiss
    
    // Snapshot for Save/Cancel
    @State private var originalLayoutSnapshot: LayoutSettingsSnapshot?
    @State private var originalTheme: Theme?
    @State private var showAdvancedSpacing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Wallpaper Settings")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .tracking(-0.3)
                
                Text("Customize your countdown display")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)
            
            // Two-Column Layout
            HStack(alignment: .top, spacing: 20) {
                // Left Column: Appearance
                VStack(alignment: .leading, spacing: 0) {
                    appearanceSection
                }
                .frame(maxWidth: .infinity)
                
                // Right Column: Layout
                VStack(alignment: .leading, spacing: 0) {
                    layoutSection
                }
                .frame(maxWidth: .infinity)
            }
            
            // Action buttons
            actionButtons
                .padding(.top, 16)
        }
        .padding(24)
        .frame(width: 580)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            // Capture original state when window opens
            originalLayoutSnapshot = layoutSettings.createSnapshot()
            originalTheme = themeStore.currentTheme
        }
        .onChange(of: layoutSettings.baseFontSize) { _ in updateWallpaperLive() }
        .onChange(of: layoutSettings.horizontalMonthSpacing) { _ in updateWallpaperLive() }
        .onChange(of: layoutSettings.verticalMonthSpacing) { _ in updateWallpaperLive() }
        .onChange(of: layoutSettings.horizontalDaySpacing) { _ in updateWallpaperLive() }
        .onChange(of: layoutSettings.verticalDaySpacing) { _ in updateWallpaperLive() }
        .onChange(of: layoutSettings.fontFamily) { _ in updateWallpaperLive() }
        .onChange(of: layoutSettings.markPassedDays) { _ in updateWallpaperLive() }
        .onChange(of: layoutSettings.showWeekendHighlight) { _ in updateWallpaperLive() }
        .onChange(of: layoutSettings.showUpdateTime) { _ in updateWallpaperLive() }
        .onChange(of: themeStore.currentTheme) { _ in updateWallpaperLive() }
    }
    
    // MARK: - Appearance Section (Left Column)
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Color Theme
            SettingsSection(title: "Color Theme", icon: "paintpalette.fill") {
                VStack(alignment: .leading, spacing: 0) {
                    // Scrollable Theme Grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(themeStore.allThemes) { theme in
                                ThemeCard(
                                    theme: theme,
                                    isSelected: themeStore.currentTheme.id == theme.id
                                ) {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        themeStore.selectTheme(theme)
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 180)
                }
            }
            
            // Typography
            SettingsSection(title: "Typography", icon: "textformat") {
                VStack(alignment: .leading, spacing: 10) {
                    Picker("", selection: $layoutSettings.fontFamily) {
                        Text("System Default").tag(".AppleSystemUIFont")
                        Divider()
                        ForEach(LayoutSettings.availableFontFamilies, id: \.self) { family in
                            Text(family).tag(family)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Font preview
                    HStack(spacing: 8) {
                        Text("Aa")
                            .font(.custom(layoutSettings.fontFamily, size: 20))
                        Text("0123456789")
                            .font(.custom(layoutSettings.fontFamily, size: 13))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.primary.opacity(0.03))
                    )
                }
            }
        }
    }
    
    // MARK: - Layout Section (Right Column)
    
    private var layoutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Calendar Density
            SettingsSection(title: "Calendar Density", icon: "square.grid.3x3") {
                VStack(alignment: .leading, spacing: 12) {
                    // Preset buttons
                    HStack(spacing: 8) {
                        ForEach(DensityPreset.allCases) { preset in
                            DensityPresetButton(
                                preset: preset,
                                isSelected: layoutSettings.currentPreset == preset
                            ) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    layoutSettings.applyPreset(preset)
                                }
                            }
                        }
                    }
                    
                    // Advanced toggle
                    DisclosureGroup(
                        isExpanded: $showAdvancedSpacing,
                        content: {
                            VStack(spacing: 10) {
                                SliderControl(
                                    label: "Font Size",
                                    value: $layoutSettings.baseFontSize,
                                    range: 8...40,
                                    unit: "pt"
                                )
                                SliderControl(
                                    label: "Month H-Spacing",
                                    value: $layoutSettings.horizontalMonthSpacing,
                                    range: 20...200,
                                    unit: "px"
                                )
                                SliderControl(
                                    label: "Month V-Spacing",
                                    value: $layoutSettings.verticalMonthSpacing,
                                    range: 0...100,
                                    unit: "px"
                                )
                                SliderControl(
                                    label: "Day H-Spacing",
                                    value: $layoutSettings.horizontalDaySpacing,
                                    range: 0...30,
                                    unit: "px"
                                )
                                SliderControl(
                                    label: "Day V-Spacing",
                                    value: $layoutSettings.verticalDaySpacing,
                                    range: 0...20,
                                    unit: "px"
                                )
                            }
                            .padding(.top, 8)
                        },
                        label: {
                            HStack(spacing: 4) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 10, weight: .medium))
                                Text("Fine-tune spacing")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(.secondary)
                        }
                    )
                    .accentColor(.secondary)
                }
            }
            
            // Display Options
            SettingsSection(title: "Display Options", icon: "eye") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(isOn: $layoutSettings.markPassedDays) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.accentColor)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Mark Passed Days")
                                    .font(.system(size: 13, weight: .semibold))
                                
                                Text("Draw a cross on days that have passed")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .toggleStyle(.switch)
                    
                    Toggle(isOn: $layoutSettings.showWeekendHighlight) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.accentColor)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Highlight Weekends")
                                    .font(.system(size: 13, weight: .semibold))
                                
                                Text("Show background color on weekend days")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .toggleStyle(.switch)
                    
                    Toggle(isOn: $layoutSettings.showUpdateTime) {
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.accentColor)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Show Update Time")
                                    .font(.system(size: 13, weight: .semibold))
                                
                                Text("Display last update timestamp on wallpaper")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .toggleStyle(.switch)
                }
            }
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    layoutSettings.reset()
                    if let firstTheme = themeStore.allThemes.first {
                        themeStore.selectTheme(firstTheme)
                    }
                }
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Reset")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color.secondary.opacity(0.08))
                )
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Button(action: cancelChanges) {
                Text("Cancel")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.secondary.opacity(0.08))
                    )
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.cancelAction)
            
            Button(action: saveAndClose) {
                Text("Save")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.accentColor)
                    )
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.defaultAction)
        }
    }
    
    // MARK: - Actions
    
    private func updateWallpaperLive() {
        Task { @MainActor in
            await wallpaperService.updateWallpaper()
        }
    }
    
    private func cancelChanges() {
        // Restore original settings
        if let snapshot = originalLayoutSnapshot {
            layoutSettings.restore(from: snapshot)
        }
        if let theme = originalTheme {
            themeStore.selectTheme(theme)
        }
        // Update wallpaper with restored settings
        updateWallpaperLive()
        dismiss()
    }
    
    private func saveAndClose() {
        // Settings are already persisted via UserDefaults in didSet
        // Just close the window
        dismiss()
    }
}

// MARK: - Settings Section Container

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.accentColor)
                
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .tracking(-0.2)
            }
            
            content
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.primary.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                        )
                )
        }
    }
}

// MARK: - Theme Card

struct ThemeCard: View {
    let theme: Theme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Color preview strip
                HStack(spacing: 2) {
                    Color(theme.background)
                    Color(theme.foreground)
                    Color(theme.accent)
                    Color(theme.weekend)
                }
                .frame(height: 24)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                
                Text(theme.name)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.accentColor : Color.primary.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Density Preset Button

struct DensityPresetButton: View {
    let preset: DensityPreset
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(preset.rawValue)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? Color.accentColor : Color.primary.opacity(0.05))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Slider Control

struct SliderControl: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 90, alignment: .leading)
            
            Slider(value: $value, in: range)
                .controlSize(.small)
            
            Text("\(Int(value))\(unit)")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 45, alignment: .trailing)
        }
    }
}

// MARK: - Settings Window Manager

class SettingsWindowManager: ObservableObject {
    private var window: NSWindow?
    private weak var wallpaperService: WallpaperService?
    private weak var themeStore: ThemeStore?
    
    func showSettings(wallpaperService: WallpaperService, themeStore: ThemeStore) {
        self.wallpaperService = wallpaperService
        self.themeStore = themeStore
        
        // Activate the app to bring it to the foreground (required for menu bar apps)
        NSApp.activate(ignoringOtherApps: true)
        
        if let window = window, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            return
        }
        
        let settingsView = SettingsWindow()
            .environmentObject(wallpaperService)
            .environmentObject(themeStore)
        let hostingController = NSHostingController(rootView: settingsView)
        
        let newWindow = NSWindow(contentViewController: hostingController)
        newWindow.title = "Settings"
        newWindow.styleMask = [.titled, .closable]
        newWindow.isReleasedWhenClosed = false
        newWindow.center()
        newWindow.setFrameAutosaveName("SettingsWindow")
        
        self.window = newWindow
        newWindow.makeKeyAndOrderFront(nil)
    }
}
