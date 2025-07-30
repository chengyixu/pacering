import SwiftUI

extension Color {
    // Primary brand color that adapts to dark mode
    static let primaryAccent = Color("PrimaryAccent")
    
    // Semantic colors for light/dark mode support
    static let cardBackground = Color("CardBackground")
    static let sidebarBackground = Color("SidebarBackground")
    static let mainBackground = Color("MainBackground")
    
    // Text colors
    static let primaryText = Color("PrimaryText")
    static let secondaryText = Color("SecondaryText")
    
    // Fallback colors
    static let fallbackPrimary = Color(light: Color(hex: "012379"), dark: Color(hex: "4A90E2"))
    static let fallbackCardBg = Color(light: .white, dark: Color(NSColor.controlBackgroundColor))
    static let fallbackSidebarBg = Color(light: .white, dark: Color(NSColor.windowBackgroundColor))
    static let fallbackMainBg = Color(light: Color(NSColor.controlBackgroundColor), dark: Color(NSColor.underPageBackgroundColor))
    
    // Initialize color with light/dark mode support
    init(light: Color, dark: Color) {
        self = Color(NSColor(name: nil, dynamicProvider: { appearance in
            switch appearance.name {
            case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
                return NSColor(dark)
            default:
                return NSColor(light)
            }
        }))
    }
    
    // Keep the hex initializer for compatibility
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xff0000) >> 16) / 255.0
        let g = Double((rgbValue & 0xff00) >> 8) / 255.0
        let b = Double(rgbValue & 0xff) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// Shadow modifiers for consistent elevation
extension View {
    func cardShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    func subtleShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
    }
}