//
//  NavFooterView.swift
//  ima/Views/Components
//
//  Created by Lloyd Derryk Mudanza Alba on 12/24/25.
//

import SwiftUI

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
    @Binding var showingCreateSheet: Bool
    @Binding var selectedTab: AppTab
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - 1. The Top Line (Edge to Edge)
            // Matches card overlay color (.white.opacity(0.15))
            Rectangle()
                .fill(.white.opacity(0.15))
                .frame(height: 1)
            
            // MARK: - 2. The Tab Buttons
            HStack(spacing: 0) {
                
                // --- Home ---
                TabButton(
                    isActive: selectedTab == .home,
                    action: { selectedTab = .home }
                ) {
                    Image(systemName: "rectangle.grid.1x3.fill")
                        .font(.title2)
                }
                
                // --- Habits ---
                TabButton(
                    isActive: selectedTab == .habits,
                    action: {
                        if selectedTab == .habits {
                            showingCreateSheet = true
                        } else {
                            selectedTab = .habits
                        }
                    }
                ) {
                    DottedRingTabIcon(isActive: selectedTab == .habits)
                }
                
                // --- Tasks ---
                TabButton(
                    isActive: selectedTab == .usertasks,
                    action: {
                        if selectedTab == .usertasks {
                            showingCreateSheet = true
                        } else {
                            selectedTab = .usertasks
                        }
                    }
                ) {
                    TaskRingTabIcon(isActive: selectedTab == .usertasks)
                }
                
                // --- Profile ---
                TabButton(
                    isActive: selectedTab == .profile,
                    action: { selectedTab = .profile }
                ) {
                    Image(systemName: "person.fill")
                        .font(.title)
                }
            }
            .frame(height: 40) // Compact height for the buttons
            .padding(.top, 10)  // Slight breathing room below the line
        }
        // MARK: - 3. Edge-to-Edge Background
        .background {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                
                Color.black
            }
            .ignoresSafeArea() // Extends behind the Home Indicator
        }
    }
}

// MARK: - Custom Icons
struct DottedRingTabIcon: View {
    var isActive: Bool
    
    // Configurable properties for "Dense" look
    let dotCount = 7 // Increased count for density
    let ringRadius: CGFloat = 16 // Tighter radius (pulled in from 20)
    let dotSize: CGFloat = 3 // Larger dots (up from 3)
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isActive ? .white : .white.opacity(0.5))
                .frame(width: 24, height: 24) // Solid core
            
            // 2. The Ring of Dots (Studs)
            ForEach(0..<dotCount, id: \.self) { index in
                Circle()
                    .fill(isActive ? .white : .white.opacity(0.5))
                    .frame(width: dotSize, height: dotSize)
                    .offset(y: -ringRadius)
                    .rotationEffect(.degrees(Double(index) / Double(dotCount) * 360))
            }
            
            // 3. The Central Plus (Cutout style)
            // We make this black (or clear) to simulate the 'filled icon' cutout look
            Image(systemName: "plus")
                .font(.headline)
                .foregroundStyle(isActive ? .black : .clear)
        }
        .frame(width: 50, height: 50)
        // Optional: Add a shadow to make it pop like a 3D button
        .shadow(color: isActive ? .white.opacity(0.3) : .clear, radius: 5)
    }
}

struct TaskRingTabIcon: View {
    var isActive: Bool
    
    var body: some View {
        ZStack {
            // 1. The Ring (No dots, just a stroke)
            Circle()
                .fill(isActive ? .white : .white.opacity(0.5))
                .frame(width: 28, height: 28) // Solid core
            
            // 2. The Checkmark (Only obvious when active, or dimmed when inactive)
            Image(systemName: isActive ? "plus" : "checkmark") // Switched to Plus when active as requested previously, or keep checkmark?
            // Reverting to your previous request: "active task tab button with the plus in it"
                .font(isActive ? .headline : .footnote)
                 .foregroundColor(.black)
        }
        .frame(width: 50, height: 50)
        .background(Color.clear) // Explicitly transparent
    }
}

// MARK: - Helper Views
struct TabButton<Content: View>: View {
    let isActive: Bool
    let action: () -> Void
    let content: () -> Content
    
    var body: some View {
        Button(action: { action() } ) {
            VStack(spacing: 4) {
                content()
            }
            .foregroundColor(isActive ? .white : .white.opacity(0.4))
            .scaleEffect(isActive ? 1.0 : 0.9)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    ZStack {
        Color.gray // To see the gradient
        VStack {
            Spacer()
            NavFooterView(showingCreateSheet: .constant(false), selectedTab: .constant(.habits))
        }
    }
}
