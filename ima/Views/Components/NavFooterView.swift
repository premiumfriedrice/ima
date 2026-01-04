//
//  NavFooterView.swift
//  ima/Views/Components
//
//  Created by Lloyd Derryk Mudanza Alba on 12/24/25.
//

import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case home = 0
    case habits = 1
    case usertasks = 2
    
    // Conforms to Identifiable for the ScrollView ID
    var id: AppTab { self }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .habits: return "Habits"
        case .usertasks: return "Tasks"
        }
    }
}

struct NavFooterView: View {
    @Binding var showingCreateSheet: Bool
    @Binding var selectedTab: AppTab
    @State private var animateArrow = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. ZStack ensures the ScrollView stays full width even when button appears
            ZStack(alignment: .trailing) {
                
                // MARK: - The Scrolling Titles
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(AppTab.allCases) { tab in
                            HStack {
                                Text(tab.title)
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    // Fade out unselected items slightly
                                    .opacity(selectedTab == tab ? 1.0 : 0.3)
                                    .animation(.snappy, value: selectedTab)
                                
                                Spacer()
                            }
                            // Forces item to match the ScrollView width exactly
                            .containerRelativeFrame(.horizontal)
                            .id(tab)
                        }
                    }
                    .scrollTargetLayout()
                }
                // *** THE FIX: Use .paging to kill momentum ***
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: Binding(
                    get: { selectedTab },
                    set: { if let new = $0 { selectedTab = new } }
                ))
                .frame(height: 45)
                
                // MARK: - The Floating Action Button
                if selectedTab != .home {
                    Button(action: { showingCreateSheet = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(10) // Larger touch target
                            .contentShape(Rectangle())
                    }
                    .accessibilityIdentifier("AddHabitButton")
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 36) // Defines the "Page Width"
            .padding(.top, 64)
            
            Color.clear.frame(height: 8)
        }
        .background(alignment: .top) {
            LinearGradient(
                stops: [
                    .init(color: Color(.black), location: 0.6),
                    .init(color: Color(.black).opacity(0), location: 1.0)
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
        }
        .onAppear {
            startArrowTimer()
        }
    }
    
    private func startArrowTimer() {
        Timer.scheduledTimer(withTimeInterval: 12.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5).repeatCount(3, autoreverses: true)) {
                animateArrow = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                animateArrow = false
            }
        }
    }
}
