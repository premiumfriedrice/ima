//
//  NavFooterView.swift
//  ima/Views/Components
//
//  Created by Lloyd Derryk Mudanza Alba on 12/24/25.
//

import SwiftUI

enum CreateSheetType: Identifiable {
    case habit, task
    var id: Self { self }
}

enum AppTab: Int, CaseIterable, Identifiable {
    case home      = 0
    case habits    = 1
    case usertasks = 2
    case profile   = 3

    // Conforms to Identifiable for the ScrollView ID
    var id: AppTab { self }

    var title: String {
        switch self {
        case .home: return "Home"
        case .habits: return "Habits"
        case .usertasks: return "Tasks"
        case .profile: return "Profile"
        }
    }
}

struct NavFooterView: View {
    @Binding var selectedTab: AppTab
    @Environment(\.appBackground) private var appBackground
    var body: some View {
        VStack(spacing: 0) {
            // Gradient hairline — fades at edges for a refined look
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.1), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)

            // Tab buttons
            HStack(spacing: 0) {
                ForEach(AppTab.allCases) { tab in
                    navTab(tab)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
            .padding(.horizontal, 16)
        }
        .background {
            ZStack {
                appBackground
                // Subtle depth gradient at the top edge
                LinearGradient(
                    colors: [.white.opacity(0.02), .clear],
                    startPoint: .top,
                    endPoint: .center
                )
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Individual Tab
    @ViewBuilder
    private func navTab(_ tab: AppTab) -> some View {
        let active = selectedTab == tab

        Button {
            selectedTab = tab
        } label: {
            tabIcon(tab, active: active)
                .frame(height: 30)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tab Icons
    @ViewBuilder
    private func tabIcon(_ tab: AppTab, active: Bool) -> some View {
        let tint: Color = active ? .white : .white.opacity(0.32)

        switch tab {
        case .home:
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(tint)
                .shadow(color: active ? .white.opacity(0.15) : .clear, radius: 8)

        case .habits:
            AtomTabIcon(isActive: active)

        case .usertasks:
            TaskTabIcon(isActive: active)

        case .profile:
            Image(systemName: "person.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(tint)
                .shadow(color: active ? .white.opacity(0.15) : .clear, radius: 8)
        }
    }
}

// MARK: - Atom Tab Icon (Habits)
/// 7 orbital dots around a nucleus — echoes the habit card's atom motif
struct AtomTabIcon: View {
    var isActive: Bool

    private let dotCount = 7
    private let nucleusSize: CGFloat = 9
    private let orbitRadius: CGFloat = 11
    private let electronSize: CGFloat = 2.5

    var body: some View {
        let tint: Color = isActive ? .white : .white.opacity(0.32)

        ZStack {
            // Nucleus
            Circle()
                .fill(tint)
                .frame(width: nucleusSize, height: nucleusSize)

            // 7 Electrons — days of the week
            ForEach(0..<dotCount, id: \.self) { i in
                let angle = Angle.degrees(360.0 / Double(dotCount) * Double(i) - 90)
                Circle()
                    .fill(tint)
                    .frame(width: electronSize, height: electronSize)
                    .offset(
                        x: orbitRadius * cos(angle.radians),
                        y: orbitRadius * sin(angle.radians)
                    )
            }
        }
        .shadow(color: isActive ? .white.opacity(0.15) : .clear, radius: 8)
    }
}

// MARK: - Task Tab Icon
/// Circle outline with checkmark — mirrors the task completion ring
struct TaskTabIcon: View {
    var isActive: Bool

    var body: some View {
        let tint: Color = isActive ? .white : .white.opacity(0.32)

        ZStack {
            Circle()
                .stroke(tint, lineWidth: 1.5)
                .frame(width: 17, height: 17)

            Image(systemName: "checkmark")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(tint)
        }
        .shadow(color: isActive ? .white.opacity(0.15) : .clear, radius: 8)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            NavFooterView(
                selectedTab: .constant(.habits)
            )
        }
    }
}
