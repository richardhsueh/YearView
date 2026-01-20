import SwiftUI
import Combine

@MainActor
class ThemeStore: ObservableObject {
    @Published var currentTheme: Theme {
        didSet {
            saveTheme()
        }
    }
    
    let allThemes: [Theme]
    
    init() {
        self.allThemes = ThemeManager.shared.allThemes
        self.currentTheme = ThemeManager.shared.currentTheme
    }
    
    func selectTheme(_ theme: Theme) {
        currentTheme = theme
        ThemeManager.shared.currentTheme = theme
    }
    
    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.identifier, forKey: "selectedTheme")
    }
}
