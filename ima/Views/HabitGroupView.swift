//
//  HabitGroupView.swift
//  ima/Views
//
//  Created by Lloyd Derryk Mudanza Alba on 12/23/25.
//

import SwiftUI
import SwiftData

struct HabitGroupView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingCreateSheet = false
    @State private var selectedTab: AppTab = .habits
    
    var habits: [Habit]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - Main Content Area
            Group {
                switch selectedTab {
                case .habits:
                    ScrollView {
                        VStack(spacing: 16) {
                            Color.clear.frame(height: 64)
                            ForEach(habits) { habit in
                                HabitCardView(habit: habit)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 150)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    
                case .tasks:
                    VStack {
                        Spacer()
                        Text("Tasks Coming Soon")
                            .foregroundStyle(.white.opacity(0.5))
                            .font(.headline)
                        Spacer()
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedTab)
            .accessibilityIdentifier("HabitList")
            
            // MARK: - Floating Footer Navigation
            NavFooterView(showingCreateSheet: $showingCreateSheet, selectedTab: $selectedTab)
        }
        .sheet(isPresented: $showingCreateSheet) {
            CreateSheetView()
        }
    }
}
