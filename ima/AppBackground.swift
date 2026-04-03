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
        case .navy:      return Color(red: 0.04, green: 0.06, blue: 0.12)
        case .midnight:  return Color(red: 0.07, green: 0.05, blue: 0.12)
        }
    }
}

// MARK: - Environment Key

private struct AppBackgroundKey: EnvironmentKey {
    static let defaultValue: Color = .black
}

extension EnvironmentValues {
    var appBackground: Color {
        get { self[AppBackgroundKey.self] }
        set { self[AppBackgroundKey.self] = newValue }
    }
}
