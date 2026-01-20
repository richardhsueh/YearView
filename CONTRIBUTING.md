# Contributing to YearView

Thank you for your interest in contributing to YearView! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/yourusername/yearview.git
   ```
3. Open the Xcode project:
   ```bash
   open YearView/YearView.xcodeproj
   ```

## Development Setup

### Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Swift 5.9 or later

### Building

1. Open the Xcode project
2. Select the `YearView` scheme
3. Build and run (Cmd+R)

## Making Changes

### Code Style

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Keep functions focused and concise

### Commit Messages

Write clear, descriptive commit messages:

```
Add new theme: Catppuccin

- Add Mocha variant with all color definitions
- Add Latte variant for light theme option
- Update theme picker to show new themes
```

### Pull Requests

1. Create a feature branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and commit them

3. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

4. Open a Pull Request against the `main` branch

5. Provide a clear description of your changes

## Types of Contributions

### Adding Themes

To add a new theme:

1. Open `YearView/YearView/Services/ThemeManager.swift`
2. Add your theme to the `allThemes` array:
   ```swift
   Theme(
       name: "Theme Name",
       identifier: "themename",
       background: "#HEXCOLOR",
       foreground: "#HEXCOLOR",
       subtext: "#HEXCOLOR",
       accent: "#HEXCOLOR",
       weekend: "#HEXCOLOR",
       error: "#HEXCOLOR",
       comment: "#HEXCOLOR"
   )
   ```
3. Update `THEMES.md` with the new theme documentation

### Bug Fixes

1. Check existing issues for duplicates
2. Create an issue if one doesn't exist
3. Reference the issue in your PR

### Feature Requests

1. Open an issue describing the feature
2. Discuss the implementation approach
3. Submit a PR once the approach is agreed upon

## Testing

Before submitting a PR:

1. Build the project successfully
2. Test the app manually:
   - Verify theme switching works
   - Check wallpaper generation
   - Test settings changes
3. Run any existing tests

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on the code, not the person
- Help others learn and grow

## Questions?

If you have questions about contributing, feel free to open an issue with the "question" label.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
