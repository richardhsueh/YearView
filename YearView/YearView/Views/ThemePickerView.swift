import SwiftUI

struct ThemePickerView: View {
    @EnvironmentObject var themeStore: ThemeStore
    @EnvironmentObject var wallpaperService: WallpaperService
    
    var body: some View {
        Menu("Theme: \(themeStore.currentTheme.name)") {
            ForEach(themeStore.allThemes) { theme in
                Button {
                    themeStore.selectTheme(theme)
                    Task {
                        await wallpaperService.updateWallpaper()
                    }
                } label: {
                    HStack {
                        Text(theme.name)
                        if theme.id == themeStore.currentTheme.id {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .id(themeStore.currentTheme.id)
    }
}
