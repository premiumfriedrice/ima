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
    
// MARK: - Date Formatters
    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d" // e.g., "DEC 28"
        return f
    }()
    
    private let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM" // e.g., "DECEMBER"
        return f
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // MARK: - Main Content Area
            Group {
                switch selectedTab {
                case .habits:
                    ScrollView {
                        // CHANGED: Use LazyVStack with pinnedViews for sticky headers
                        LazyVStack(spacing: 24, pinnedViews: [.sectionHeaders]) {
                            
                            // Keep your spacer for top safe area/nav bar
                            Color.clear.frame(height: 0)
                            
                            // MARK: - Daily Section
                            if !dailyHabits.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Daily",
                                    subtitle: dayFormatter.string(from: Date()),
                                    icon: "sun.max.fill",
                                    color: .orange)) {
                                    ForEach(dailyHabits) { habit in
                                        HabitCardView(habit: habit)
                                    }
                                }
                            }
                            
                            // MARK: - Weekly Section
                            if !weeklyHabits.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Weekly",
                                    subtitle: currentWeekRange,
                                    icon: "calendar",
                                    color: .blue)) {
                                    ForEach(weeklyHabits) { habit in
                                        HabitCardView(habit: habit)
                                    }
                                }
                            }
                            
                            // MARK: - Monthly Section
                            if !monthlyHabits.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Monthly",
                                    subtitle: monthFormatter.string(from: Date()),
                                    icon: "moon.stars.fill",
                                    color: .purple)) {
                                    ForEach(monthlyHabits) { habit in
                                        HabitCardView(habit: habit)
                                    }
                                }
                            }
                            
                            // Empty State
                            if habits.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "tray")
                                        .font(.system(size: 60)) // Set icon size explicitly
                                        .foregroundStyle(.white.opacity(0.5)) // Match your opacity
                                    
                                    VStack {
                                        Text("No Habits Yet")
                                            .font(.system(.title2, design: .rounded)) // Explicitly Rounded
                                            .fontWeight(.bold)
                                        
                                        Text("Tap the + button to create your first habit.")
                                            .font(.system(.body, design: .rounded))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 40)
                                    }
                                }
                                .padding(.top, 40)
                                .font(.system(.caption, design: .rounded))
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 16) // Increased slightly for the headers
                        
                        Color.clear
                                .frame(height: 160)
                                .accessibilityHidden(true)
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
    
    // MARK: - Filtering Logic
    private var dailyHabits: [Habit] {
        habits.filter { $0.frequencyUnit == .daily }
    }
    
    private var weeklyHabits: [Habit] {
        habits.filter { $0.frequencyUnit == .weekly }
    }
    
    private var monthlyHabits: [Habit] {
        habits.filter { $0.frequencyUnit == .monthly }
    }
    
// MARK: - Date Range Calculation
    private var currentWeekRange: String {
        let calendar = Calendar.current
        let today = Date()
        
        // Calculate start of week (Sunday or Monday based on locale)
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today)
        guard let start = weekInterval?.start, let end = weekInterval?.end else { return "" }
        
        // End date is technically start of next week, subtract 1 second to get Saturday/Sunday night
        let actualEnd = end.addingTimeInterval(-1)
        
        let startStr = dayFormatter.string(from: start)
        let endStr = dayFormatter.string(from: actualEnd)
        
        return "\(startStr) - \(endStr)"
    }
}

// MARK: - Subviews

/// A reusable, sticky header component
struct SectionHeader: View {
    let title: String
    let subtitle: String // Added subtitle
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(color)
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .textCase(.uppercase)
            
            // Divider Dot
            Circle()
                .fill(.white.opacity(0.3))
                .frame(width: 4, height: 4)
            
            // Date/Subtitle
            Text(subtitle)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            
            Spacer()
        }
        .font(.system(.caption, design: .rounded))
        .fontWeight(.bold)
        .textCase(.uppercase)
        .kerning(1.0)
        .opacity(0.5)
        .foregroundStyle(.white)
        .padding(.leading, 16)
    }
}

#Preview {
    let habits = [
        Habit(title: "LeetCode", frequencyCount: 1, frequencyUnit: .daily),
        Habit(title: "Pray", frequencyCount: 3, frequencyUnit: .daily),
        Habit(title: "Ride Motorcycle", frequencyCount: 1, frequencyUnit: .daily),
        Habit(title: "Lift", frequencyCount: 4, frequencyUnit: .weekly),
        Habit(title: "Cardio", frequencyCount: 3, frequencyUnit: .weekly),
        Habit(title: "Read Book", frequencyCount: 2, frequencyUnit: .monthly),
        Habit(title: "Clean Motorcycle Chain", frequencyCount: 2, frequencyUnit: .monthly),
        Habit(title: "Clean Restroom", frequencyCount: 2, frequencyUnit: .monthly),
        ]
    
    ZStack {
        Color(.black).ignoresSafeArea()
        AnimatedRadialBackground()
        HabitGroupView(habits: habits)
    }
        
}
