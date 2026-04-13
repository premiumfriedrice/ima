//
//  AppBackground.swift
//  ima
//
//  Defines background color options and a custom EnvironmentKey
//  so every view can read the user's chosen background.
//

import SwiftUI

enum AppBackground: String, CaseIterable, Identifiable {
    case pureBlack  = "Pure Black"
    case charcoal   = "Charcoal"
    case graphite   = "Graphite"
    case navy       = "Navy"
    case midnight   = "Midnight"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .pureBlack: return .black
        case .charcoal:  return Color(red: 0.08, green: 0.08, blue: 0.09)
        case .graphite:  return Color(red: 0.11, green: 0.11, blue: 0.12)
        case .navy:      return Color(red: 0.06, green: 0.09, blue: 0.18)
        case .midnight:  return Color(red: 0.10, green: 0.07, blue: 0.18)
        }
    }

    /// Alternate icon name — nil means use the default (black) icon
    var iconName: String? {
        switch self {
        case .pureBlack: return "AppIcon-black"
        case .charcoal:  return nil
        case .graphite:  return "AppIcon-graphite"
        case .navy:      return "AppIcon-navy"
        case .midnight:  return "AppIcon-midnight"
        }
    }
}

// MARK: - Environment Key

private struct AppBackgroundKey: EnvironmentKey {
    static let defaultValue: Color = Color(red: 0.08, green: 0.08, blue: 0.09)
}

extension EnvironmentValues {
    var appBackground: Color {
        get { self[AppBackgroundKey.self] }
        set { self[AppBackgroundKey.self] = newValue }
    }
}
