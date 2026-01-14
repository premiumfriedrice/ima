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
        // Sorting by current count descending (High -> Low)
        let sorted = habits.sorted { $0.currentCount > $1.currentCount }
        return Array(sorted.prefix(3)) // Top 3
    }
    
    private var weakestHabits: [Habit] {
        // Sorting by current count ascending (Low -> High)
        // Filter out brand new habits (0 count) if you want, or keep them to show what needs work
        let sorted = habits.sorted { $0.currentCount < $1.currentCount }
        return Array(sorted.prefix(3)) // Bottom 3
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Header
                    HStack {
                        // Settings Gear (Left or Right based on pref, usually Right)
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(12)
                                .background(.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text("Profile")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .opacity(0.0) // Invisible spacer text to balance if needed, or remove
                        
                        Spacer()
                        
                        // Close Button
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(12)
                                .background(.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Profile Card (User Loved This)
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 70, height: 70)
                                .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)
                            
                            Text("LM") // Initials
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Lloyd Alba")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.black)
                                .foregroundStyle(.white)
                            
                            Text("CS Student • Texas A&M")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        
                        Spacer()
                    }
                    .padding(24)
                    .background {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(.ultraThinMaterial.opacity(0.1))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    }
                    
                    // MARK: - Main Stat: Total Tasks (The "Trophy Count")
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("TASKS COMPLETED")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.5))
                                .kerning(1)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(totalTasksCompleted)")
                                    .font(.system(size: 48, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                
                                Text("total")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                        }
                        Spacer()
                        
                        // Icon Decoration
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                            .shadow(color: .orange.opacity(0.5), radius: 10)
                    }
                    .padding(24)
                    .background {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial.opacity(0.1))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    }
                    
                    // MARK: - Strongest Habits
                    if !strongestHabits.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Strongest Habits", icon: "crown.fill", color: .yellow)
                            
                            VStack(spacing: 12) {
                                ForEach(strongestHabits) { habit in
                                    StatRow(habit: habit, type: .strong)
                                }
                            }
                        }
                    }
                    
                    // MARK: - Weakest Habits
                    if !weakestHabits.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Needs Improvement", icon: "exclamationmark.triangle.fill", color: .red)
                            
                            VStack(spacing: 12) {
                                ForEach(weakestHabits) { habit in
                                    StatRow(habit: habit, type: .weak)
                                }
                            }
                        }
                    }
                    
                    // Bottom Padding
                    Color.clear.frame(height: 50)
                }
                .padding(.horizontal, 20)
            }
        }
        // Present Settings Sheet
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
            // Rank Indicator
            Circle()
                .fill(type.color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: type == .strong ? "arrow.up" : "arrow.down")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(type.color)
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("\(habit.currentCount) completions")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            Spacer()
            
            // Percentage or Score (Simplified visual)
            Capsule()
                .fill(type.color.opacity(0.1))
                .frame(width: 60, height: 24)
                .overlay {
                    Text(type == .strong ? "TOP" : "LOW")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(type.color)
                }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial.opacity(0.1))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.05), lineWidth: 1)
        }
    }
}

#Preview {
    ProfileView()
}
