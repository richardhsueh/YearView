//
//  ThemeManager.swift
//  YearView
//
//  Manages all available themes
//

import Foundation

class ThemeManager {
    static let shared = ThemeManager()
    
    private let userDefaultsKey = "selectedTheme"
    
    let allThemes: [Theme] = [
        // Enhanced Nord with full color palette
        Theme(name: "Nord", identifier: "nord", background: "#2E3440", foreground: "#ECEFF4", subtext: "#D8DEE9", accent: "#88C0D0", weekend: "#3B4252", strikethrough: "#BF616A", muted: "#4C566A"),
        
        // Enhanced Dracula with full color palette
        Theme(name: "Dracula", identifier: "dracula", background: "#282A36", foreground: "#F8F8F2", subtext: "#6272A4", accent: "#BD93F9", weekend: "#44475A", strikethrough: "#FF5555", muted: "#6272A4"),
        
        // Enhanced Gruvbox with full color palette
        Theme(name: "Gruvbox", identifier: "gruvbox", background: "#282828", foreground: "#EBDBB2", subtext: "#928374", accent: "#FABD2F", weekend: "#3C3836", strikethrough: "#FB4934", muted: "#665C54"),
        
        // Enhanced Monokai with full color palette
        Theme(name: "Monokai", identifier: "monokai", background: "#272822", foreground: "#F8F8F2", subtext: "#75715E", accent: "#F92672", weekend: "#3E3D32", strikethrough: "#F92672", muted: "#75715E"),
        
        // Enhanced Light with full color palette
        Theme(name: "Light", identifier: "light", background: "#FFFFFF", foreground: "#24292E", subtext: "#6A737D", accent: "#0366D6", weekend: "#F6F8FA", strikethrough: "#D73A49", muted: "#6A737D"),
        
        // Enhanced Dark with full color palette
        Theme(name: "Dark", identifier: "dark", background: "#1E1E1E", foreground: "#D4D4D4", subtext: "#808080", accent: "#569CD6", weekend: "#252525", strikethrough: "#F48771", muted: "#608B4E"),
        
        // Enhanced 8008 with full color palette
        Theme(name: "8008", identifier: "8008", background: "#333A45", foreground: "#F7F2EA", subtext: "#F44C7F", accent: "#F44C7F", weekend: "#3D4555", strikethrough: "#EF596F", muted: "#52606D"),
        
        // Enhanced 9009 with full color palette
        Theme(name: "9009", identifier: "9009", background: "#F5E6D3", foreground: "#3D3839", subtext: "#9C8D7B", accent: "#CE7E6C", weekend: "#E8D7C3", strikethrough: "#B85651", muted: "#9C8D7B"),
        
        // Enhanced Olivia with full color palette
        Theme(name: "Olivia", identifier: "olivia", background: "#2C2A2C", foreground: "#E8DED6", subtext: "#B5A99C", accent: "#E3B5A4", weekend: "#363436", strikethrough: "#D98B8B", muted: "#726969"),
        
        // Enhanced Serika with full color palette
        Theme(name: "Serika", identifier: "serika", background: "#323437", foreground: "#E3E3E3", subtext: "#A0A0A0", accent: "#E5B567", weekend: "#3D3F43", strikethrough: "#CA4754", muted: "#646669"),
        
        // Enhanced Mizu with full color palette
        Theme(name: "Mizu", identifier: "mizu", background: "#F7F9FB", foreground: "#353B45", subtext: "#6B7885", accent: "#70C1E0", weekend: "#EDF2F7", strikethrough: "#E65A65", muted: "#A1B5C4"),
        
        // Enhanced Carbon with full color palette
        Theme(name: "Carbon", identifier: "carbon", background: "#292929", foreground: "#F2F2F2", subtext: "#7C7C7C", accent: "#F39C12", weekend: "#333333", strikethrough: "#E74C3C", muted: "#595959"),
        
        // Enhanced Phantom with full color palette
        Theme(name: "Phantom", identifier: "phantom", background: "#0E0E12", foreground: "#F5F5F5", subtext: "#888B8D", accent: "#53D3D1", weekend: "#16161C", strikethrough: "#FE4450", muted: "#454B54"),
        
        // Enhanced Sakura with full color palette
        Theme(name: "Sakura", identifier: "sakura", background: "#FFF5F7", foreground: "#5C3349", subtext: "#D4A5A5", accent: "#FFC0CB", weekend: "#FFE8EC", strikethrough: "#E85D75", muted: "#F4C2C2"),
        
        // Enhanced Aurora with full color palette
        Theme(name: "Aurora", identifier: "aurora", background: "#0F0F23", foreground: "#E5E9F0", subtext: "#81A1C1", accent: "#88C0D0", weekend: "#1A1A2E", strikethrough: "#BF616A", muted: "#5E81AC"),
        
        // New Themes from GitHub
        
        // Hyperfuse - purple and teal accents
        Theme(name: "Hyperfuse", identifier: "hyperfuse", background: "#727474", foreground: "#C6C9C7", subtext: "#9A9C9E", accent: "#00A4A9", weekend: "#606262", strikethrough: "#FF6B9D", muted: "#5D437E"),
        
        // Space Cadet - deep blue space theme
        Theme(name: "Space Cadet", identifier: "spacecadet", background: "#1D2951", foreground: "#E4E4E4", subtext: "#BEBEBE", accent: "#555E88", weekend: "#29274C", strikethrough: "#FF6B9D", muted: "#9F9F9F"),
        
        // Godspeed - retro space theme with gold accents
        Theme(name: "Godspeed", identifier: "godspeed", background: "#EEE2D0", foreground: "#393B3B", subtext: "#00627A", accent: "#EBD400", weekend: "#E0D4C2", strikethrough: "#F44747", muted: "#0084C2"),
        
        // Solarized Dark - popular dark theme
        Theme(name: "Solarized Dark", identifier: "solarizeddark", background: "#002B36", foreground: "#839496", subtext: "#586E75", accent: "#268BD2", weekend: "#073642", strikethrough: "#DC322F", muted: "#657B83"),
        
        // Solarized Light - popular light theme
        Theme(name: "Solarized Light", identifier: "solarizedlight", background: "#FDF6E3", foreground: "#657B83", subtext: "#93A1A1", accent: "#268BD2", weekend: "#EEE8D5", strikethrough: "#DC322F", muted: "#93A1A1"),
        
        // Nautilus - blue ocean theme
        Theme(name: "Nautilus", identifier: "nautilus", background: "#1D2228", foreground: "#F0F0F0", subtext: "#858E96", accent: "#4DB5BD", weekend: "#282C34", strikethrough: "#FF6C6B", muted: "#5B6268"),
        
        // Oblivion - dark purple theme
        Theme(name: "Oblivion", identifier: "oblivion", background: "#1C1A20", foreground: "#E3E1E4", subtext: "#A39FA9", accent: "#9580FF", weekend: "#28242E", strikethrough: "#FF6188", muted: "#727072"),
        
        // Yuri - purple and pink theme
        Theme(name: "Yuri", identifier: "yuri", background: "#282A36", foreground: "#F8F8F2", subtext: "#BE90D4", accent: "#FFB8D1", weekend: "#363848", strikethrough: "#FF79C6", muted: "#9580FF"),
        
        // Vilebloom - green and purple theme
        Theme(name: "Vilebloom", identifier: "vilebloom", background: "#1C1B1D", foreground: "#CCCCCC", subtext: "#8F8F8F", accent: "#6EC971", weekend: "#26252A", strikethrough: "#CF68E1", muted: "#B0B0B0"),
        
        // Handarbeit - warm beige theme
        Theme(name: "Handarbeit", identifier: "handarbeit", background: "#F4E8D8", foreground: "#5F5A52", subtext: "#9B8B7E", accent: "#D4866A", weekend: "#EAE0D0", strikethrough: "#C84639", muted: "#B39F8D"),
        
        // Kobayashi - japanese inspired theme
        Theme(name: "Kobayashi", identifier: "kobayashi", background: "#292C33", foreground: "#E8E3E3", subtext: "#A09B9B", accent: "#FF6A7D", weekend: "#353842", strikethrough: "#FF5252", muted: "#6E6E6E"),
        
        // Honeywell - retro terminal theme
        Theme(name: "Honeywell", identifier: "honeywell", background: "#FFF1E0", foreground: "#473C33", subtext: "#8F7E6F", accent: "#E07C3E", weekend: "#F5E5D3", strikethrough: "#D64541", muted: "#A9958A"),
        
        // Dots - minimalist theme
        Theme(name: "Dots", identifier: "dots", background: "#1D2021", foreground: "#EBDBB2", subtext: "#A89984", accent: "#83A598", weekend: "#282828", strikethrough: "#FB4934", muted: "#928374"),
        
        // Leviathan - deep ocean theme
        Theme(name: "Leviathan", identifier: "leviathan", background: "#0A0E14", foreground: "#C7CCD1", subtext: "#7A8188", accent: "#4DBCE9", weekend: "#14191F", strikethrough: "#FF3333", muted: "#626A73"),
        
        // Modern Dolch - modern gray theme
        Theme(name: "Modern Dolch", identifier: "moderndolch", background: "#2D2A2E", foreground: "#FCFCFA", subtext: "#939293", accent: "#FF6188", weekend: "#3A3739", strikethrough: "#FF6188", muted: "#727072"),
        
        // Mr Sleeves - blue and gold theme
        Theme(name: "Mr Sleeves", identifier: "mrsleeves", background: "#16161D", foreground: "#E9E9EA", subtext: "#8E8E93", accent: "#FFD60A", weekend: "#1F1F28", strikethrough: "#FF453A", muted: "#636366"),
        
        // Eclipse - dark theme with orange accents
        Theme(name: "Eclipse", identifier: "eclipse", background: "#2B2B2B", foreground: "#E0E0E0", subtext: "#969696", accent: "#FF8F40", weekend: "#343434", strikethrough: "#F44747", muted: "#7A7A7A"),
        
        // Denim - blue denim theme
        Theme(name: "Denim", identifier: "denim", background: "#1E2A3A", foreground: "#E3E8EF", subtext: "#8A9BA8", accent: "#5DADE2", weekend: "#283848", strikethrough: "#E74C3C", muted: "#546E7A"),
        
        // Burgundy - rich red theme
        Theme(name: "Burgundy", identifier: "burgundy", background: "#2A1A1F", foreground: "#E8DFE0", subtext: "#B39093", accent: "#A4243B", weekend: "#341F25", strikethrough: "#D81B60", muted: "#826164"),
        
        // Rama - minimalist black theme
        Theme(name: "Rama", identifier: "rama", background: "#0F0F0F", foreground: "#E0E0E0", subtext: "#7A7A7A", accent: "#4A4A4A", weekend: "#1A1A1A", strikethrough: "#CF6679", muted: "#525252"),
        
        // 1976 - retro brown theme
        Theme(name: "1976", identifier: "1976", background: "#B87333", foreground: "#F5E6D3", subtext: "#E0D3C0", accent: "#FFD700", weekend: "#A86628", strikethrough: "#FF4444", muted: "#D4A574")
    ]
    
    var currentTheme: Theme {
        get {
            let identifier = UserDefaults.standard.string(forKey: userDefaultsKey) ?? "nord"
            return allThemes.first(where: { $0.identifier == identifier }) ?? allThemes[0]
        }
        set {
            UserDefaults.standard.set(newValue.identifier, forKey: userDefaultsKey)
            NotificationCenter.default.post(name: .themeDidChange, object: newValue)
        }
    }
    
    private init() {}
    
    func theme(for identifier: String) -> Theme? {
        return allThemes.first(where: { $0.identifier == identifier })
    }
    
    func themesSortedByName() -> [Theme] {
        return allThemes.sorted { $0.name < $1.name }
    }
}

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}
