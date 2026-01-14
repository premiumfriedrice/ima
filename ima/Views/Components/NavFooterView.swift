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
            
            // MARK: - The Tab Buttons
            HStack(spacing: 0) {
                
                // --- 1. Home Tab ---
                TabButton(
                    isActive: selectedTab == .home,
                    action: { selectedTab = .home }
                ) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 24))
                }
                
                // --- 2. Habits Tab (Dots + Inner Ring) ---
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
                
                // --- 3. Tasks Tab (Ring + Checkmark/Plus) ---
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
                
                TabButton(
                    isActive: selectedTab == .profile,
                    action: {
                        selectedTab = .profile
                    }
                ) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                }
            }
            .padding(.top, 20)
            .frame(height: 80) // Height of the touch area
            .padding(.horizontal, 24)
            
            // Bottom spacer for safe area
            Color.clear.frame(height: 0)
        }
        .background(alignment: .top) {
            LinearGradient(
                stops: [
                    .init(color: Color(.black), location: 0.7),
                    .init(color: Color(.black).opacity(0), location: 1.0)
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Custom Icons

struct DottedRingTabIcon: View {
    var isActive: Bool
    
    // Configurable properties
    let dotCount = 7
    let ringRadius: CGFloat = 20 // The radius for the dots
    let dotSize: CGFloat = 3
    
    var body: some View {
        ZStack {
            // 1. The Inner Ring (New addition based on request)
            // Sits inside the dots, enclosing the Plus
            Circle()
                .stroke(isActive ? Color.white : Color.gray.opacity(0.3), lineWidth: 1.5)
                .frame(width: 28, height: 28) // Smaller than the dot radius (20*2=40)
            
            // 2. The Ring of Dots (Outer Layer)
            ForEach(0..<dotCount, id: \.self) { index in
                Circle()
                    .fill(isActive ? Color.white : Color.gray.opacity(0.5))
                    .frame(width: dotSize, height: dotSize)
                    .offset(y: -ringRadius)
                    .rotationEffect(.degrees(Double(index) / Double(dotCount) * 360))
            }
            
            // 3. The Central Plus
            if isActive {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold)) // Slightly smaller to fit in inner ring
                    .foregroundColor(isActive ? .white : .gray.opacity(0.5))
            }
        }
        .frame(width: 50, height: 50) // Hit target size
    }
}

struct TaskRingTabIcon: View {
    var isActive: Bool
    
    var body: some View {
        ZStack {
            // 1. The Ring (No dots, just a stroke)
            Circle()
                .stroke(isActive ? Color.white : Color.gray.opacity(0.5), lineWidth: 2)
                .frame(width: 28, height: 28) // Matches visual size of the dotted ring's outer bounds
            
            // 2. The Checkmark (Only obvious when active, or dimmed when inactive)
            Image(systemName: isActive ? "plus" : "checkmark") // Switched to Plus when active as requested previously, or keep checkmark?
            // Reverting to your previous request: "active task tab button with the plus in it"
                 .font(.system(size: 14, weight: .bold))
                 .foregroundColor(isActive ? .white : .gray.opacity(0.3))
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
        Button(action: {
            withAnimation(.snappy) {
                action()
            }
        }) {
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
