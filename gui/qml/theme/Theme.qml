pragma Singleton
import QtQuick

/**
 * Theme - Global color palette and styling for Mangapill Downloader
 * Dark glassmorphism theme with neon accents
 */
QtObject {
    // ==================== Colors ====================
    
    // Backgrounds
    readonly property color bgPrimary: "#0D0D1A"      // Deep Space
    readonly property color bgSecondary: "#1A1A2E"   // Dark Purple
    readonly property color bgCard: "#16213E"        // Navy (use with opacity)
    readonly property color bgCardHover: "#1E2A4A"   // Navy Lighter
    
    // Accent Colors
    readonly property color accentPrimary: "#00D9FF"   // Cyan Neon
    readonly property color accentSecondary: "#FF6B9D" // Pink Neon
    readonly property color accentTertiary: "#7B68EE"  // Purple Glow
    
    // Status Colors
    readonly property color success: "#00FF88"  // Mint Green
    readonly property color warning: "#FFB347"  // Orange
    readonly property color error: "#FF4757"    // Red
    
    // Text Colors
    readonly property color textPrimary: "#FFFFFF"
    readonly property color textSecondary: "#B8B8D1"
    readonly property color textMuted: "#6B6B8D"
    
    // Border Colors
    readonly property color borderLight: "#FFFFFF20"
    readonly property color borderAccent: "#00D9FF40"
    
    // ==================== Typography ====================
    
    readonly property string fontFamily: "Segoe UI, Inter, -apple-system, sans-serif"
    
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeMedium: 14
    readonly property int fontSizeLarge: 16
    readonly property int fontSizeXLarge: 20
    readonly property int fontSizeTitle: 28
    readonly property int fontSizeHero: 36
    
    // ==================== Spacing ====================
    
    readonly property int spacingXS: 4
    readonly property int spacingS: 8
    readonly property int spacingM: 16
    readonly property int spacingL: 24
    readonly property int spacingXL: 32
    readonly property int spacingXXL: 48
    
    // ==================== Borders & Radius ====================
    
    readonly property int radiusS: 8
    readonly property int radiusM: 12
    readonly property int radiusL: 16
    readonly property int radiusXL: 24
    readonly property int radiusRound: 9999
    
    // ==================== Shadows ====================
    
    readonly property color shadowColor: "#00000060"
    readonly property color glowCyan: "#00D9FF80"
    readonly property color glowPink: "#FF6B9D80"
    readonly property color glowPurple: "#7B68EE80"
    
    // ==================== Animation Durations ====================
    
    readonly property int animFast: 150
    readonly property int animNormal: 250
    readonly property int animSlow: 350
    readonly property int animVerySlow: 500
    
    // ==================== Card Styling ====================
    
    readonly property real cardOpacity: 0.85
    readonly property int cardBlurRadius: 32
}
