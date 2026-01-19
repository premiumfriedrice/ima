//
//  ProfileView.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 1/13/26.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Data Queries
    @Query private var tasks: [UserTask]
    @Query private var habits: [Habit]
    
    // State for Settings Sheet
    @State private var showSettings = false
    
    // MARK: - Computed Stats
    
    private var totalTasksCompleted: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    private var strongestHabits: [Habit] {
        let sorted = habits.sorted { $0.currentCount > $1.currentCount }
        return Array(sorted.prefix(3))
    }
    
    private var weakestHabits: [Habit] {
        let sorted = habits.sorted { $0.currentCount < $1.currentCount }
        return Array(sorted.prefix(3))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) { // Increased spacing to match InfoView rhythm
                    
                    // MARK: - Top Nav
                    HStack {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(10)
                                .background(.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Profile Hero
                    VStack(spacing: 20) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 80, height: 80)
                                .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)
                            
                            Text("LA") // Initials
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                        
                        // Text Info
                        VStack(spacing: 8) {
                            Text("Lloyd Alba")
                                .font(.title2) // Matches Hero Title in InfoViews
                                .foregroundStyle(.white)
                            
                            Text("CS Student • Texas A&M")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    
                    // MARK: - Main Stat (Tasks)
                    VStack(alignment: .leading, spacing: 10) {
                        // Section Header Style
                        Text("LIFETIME STATS")
                            .font(.caption2)
                            .textCase(.uppercase)
                            .kerning(1.0)
                            .opacity(0.5)
                            .foregroundStyle(.white)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text("\(totalTasksCompleted)")
                                        .font(.system(size: 42, weight: .regular)) // Cleaner number font
                                        .foregroundStyle(.white)
                                    
                                    Text("tasks")
                                        .font(.subheadline)
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                
                                Text("Total completed")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                            Spacer()
                            
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                                .shadow(color: .orange.opacity(0.3), radius: 8)
                        }
                        .padding(20)
                        .background(.white.opacity(0.05)) // Matches InfoView container style
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    
                    // MARK: - Strongest Habits
                    if !strongestHabits.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("STRONGEST HABITS")
                                .font(.caption2)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            VStack(spacing: 8) {
                                ForEach(strongestHabits) { habit in
                                    StatRow(habit: habit, type: .strong)
                                }
                            }
                        }
                    }
                    
                    // MARK: - Weakest Habits
                    if !weakestHabits.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("NEEDS IMPROVEMENT")
                                .font(.caption2)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            VStack(spacing: 8) {
                                ForEach(weakestHabits) { habit in
                                    StatRow(habit: habit, type: .weak)
                                }
                            }
                        }
                    }
                    
                    Color.clear.frame(height: 50)
                }
                .padding(.horizontal, 25) // Matches padding in InfoViews
            }
            .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Helper Views

enum StatType {
    case strong
    case weak
    
    var color: Color {
        switch self {
        case .strong: return .green
        case .weak: return .red
        }
    }
}

struct StatRow: View {
    let habit: Habit
    let type: StatType
    
    var body: some View {
        HStack {
            // Simple Dot Indicator
            Circle()
                .fill(type.color.opacity(0.8))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.title)
                    .font(.subheadline) // Matches subtask text style
                    .foregroundStyle(.white)
                
                Text("\(habit.currentCount) completions")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            Spacer()
            
            // Minimal Badge
            Text(type == .strong ? "TOP" : "LOW")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(type.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(type.color.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(16)
        .background(.white.opacity(0.05)) // Matches subtask container
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ProfileView()
}
