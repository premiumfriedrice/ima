//
//  HabitInfoView.swift
//  ima/Views/HabitViews
//
//  Created by Lloyd Derryk Mudanza Alba on 12/23/25.
//

import SwiftUI
import SwiftData

struct HabitInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var habit: Habit
    
    @State private var showingDeleteConfirmation = false
    @State private var showingResetConfirmation = false
    @State private var isEditing = false
    @State private var currentDetent: PresentationDetent = .medium
    
    // Grid layout for statistics
    private let statColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // MARK: - Swipe Pill
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 20)
                
                // MARK: - Header
                HStack {
                    // Edit Button
                    Button {
                        withAnimation(.snappy) {
                            isEditing.toggle()
                            if isEditing { currentDetent = .large }
                        }
                    } label: {
                        Image(systemName: isEditing ? "checkmark" : "square.and.pencil")
                            .font(.callout)
                            .foregroundStyle(isEditing ? .white : .white.opacity(0.6))
                            .padding(10)
                            .background(
                                ZStack {
                                    if isEditing {
                                        LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    } else {
                                        Color.white.opacity(0.1)
                                    }
                                }
                            )
                            .clipShape(Circle())
                    }
                    
                    // Reset Button
                    Button { showingResetConfirmation = true } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.callout)
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(10)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Delete Button
                    Button(role: .destructive) { showingDeleteConfirmation = true } label: {
                        Image(systemName: "trash")
                            .font(.callout)
                            .foregroundStyle(.red.opacity(0.8))
                            .padding(10)
                            .background(.red.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 32) {
                            
                            // MARK: - Hero Title
                            VStack(alignment: .leading, spacing: 10) {
                                Text("HABIT")
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)
                                Text(habit.title)
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 25)
                            
                            // MARK: - Today's Progress
                            VStack(alignment: .leading, spacing: 10) {
                                Text("TODAY'S PROGRESS")
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)
                                
                                HStack(spacing: 20) {
                                    Button { decrementProgress() } label: {
                                        Image(systemName: "minus")
                                            .font(.callout)
                                            .foregroundStyle(.white)
                                            .frame(width: 50, height: 50)
                                            .background(.white.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                    .padding(.bottom, 25)
                                    
                                    GeometryReader { geo in
                                        ProgressRingWithDots(habit: habit, fillFactor: 0.9) {
                                            VStack(spacing: 0) {
                                                Text("\(habit.currentCount)")
                                                    .font(.largeTitle)
                                                    .bold()
                                                    .foregroundStyle(.white)
                                                    .contentTransition(.numericText(value: Double(habit.currentCount)))
                                                
                                                Text("/ \(habit.frequencyCount)")
                                                    .font(.callout)
                                                    .foregroundStyle(.white.opacity(0.5))
                                            }
                                        }
                                    }
                                    .frame(height: 250)
                                    
                                    Button { incrementProgress() } label: {
                                        Image(systemName: "plus")
                                            .font(.callout)
                                            .foregroundStyle(.black)
                                            .frame(width: 50, height: 50)
                                            .background(.white)
                                            .clipShape(Circle())
                                            .shadow(color: .white.opacity(0.2), radius: 10, x: 0, y: 0)
                                    }
                                    .padding(.bottom, 25)
                                }
                            }
                            .padding(.horizontal, 25)
                            
                            // MARK: - History Heatmap
                            HistoryHeatmap(habit: habit)
                            
                            // MARK: - Statistics Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("STATISTICS")
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)
                                
                                LazyVGrid(columns: statColumns, spacing: 15) {
                                    // 1. Average Completion Rate
                                    StatCard(
                                        title: "Avg. Completion",
                                        value: completionRateString,
                                        icon: "chart.bar.fill",
                                        color: .blue
                                    )
                                    
                                    // 2. Perfect Days/Weeks/Months
                                    StatCard(
                                        title: perfectCountLabel,
                                        value: "\(perfectCount)",
                                        icon: "star.fill",
                                        color: .yellow
                                    )
                                }
                            }
                            .padding(.horizontal, 25)
                            
                            // MARK: - Adjust Goal
                            if isEditing {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("ADJUST YOUR GOAL")
                                        .font(.system(.caption, design: .rounded))
                                        .textCase(.uppercase)
                                        .kerning(1.0)
                                        .opacity(0.5)
                                        .foregroundStyle(.white)
                                    
                                    HStack(spacing: 0) {
                                        Picker("Count", selection: $habit.frequencyCount) {
                                            ForEach(1...50, id: \.self) { number in
                                                Text("\(number)")
                                                    .font(.system(size: 28, design: .rounded))
                                                    .foregroundStyle(.white)
                                                    .tag(number)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 72, height: 128)
                                        .compositingGroup()
                                        
                                        Text(habit.frequencyCount == 1 ? "time per" : "times per")
                                            .font(.system(size: 28, design: .rounded))
                                            .foregroundStyle(.white.opacity(0.4))
                                            .padding(.horizontal, 8)
                                        
                                        Picker("Frequency", selection: $habit.frequencyUnitRaw) {
                                            ForEach(FrequencyUnit.allCases, id: \.self) { unit in
                                                Text(unit.rawValue.capitalized)
                                                    .font(.system(size: 28, design: .rounded))
                                                    .foregroundStyle(.white)
                                                    .tag(unit.rawValue)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 136, height: 128)
                                        .compositingGroup()
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal, 25)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .id("AdjustGoalSection")
                            }
                            
                            Spacer()
                            
                            Text("Created " + habit.dateCreated.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                                .padding(.bottom, 20)
                        }
                        .padding(.top, 20)
                    }
                    .onChange(of: isEditing) { _, newValue in
                        if newValue {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    proxy.scrollTo("AdjustGoalSection", anchor: .center)
                                }
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .foregroundStyle(.white)
        .overlay {
            RoundedRectangle(cornerRadius: 40)
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.2), location: 0.0),
                            .init(color: .white.opacity(0.05), location: 0.2),
                            .init(color: .clear, location: 0.5)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 3
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .presentationDetents([.medium, .large], selection: $currentDetent)
        .presentationDragIndicator(.hidden)
        .presentationBackground(.black)
        .presentationCornerRadius(40)
        .confirmationDialog(
            "Are you sure you want to delete '\(habit.title)'?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Habit", role: .destructive) {
                dismiss()
                Task {
                    try? await Task.sleep(for: .seconds(0.35))
                    modelContext.delete(habit)
                }
            }
            Button("Cancel") { }
        } message: {
            Text("This action cannot be undone.")
        }
        .confirmationDialog(
            "Are you sure you want to reset '\(habit.title)'?",
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Todays Progress", role: .destructive) {
                withAnimation { habit.resetCurrentProgress() }
            }
            Button("Cancel") { }
        } message: {
            Text("This action will reset progress for this habit for today.")
        }
    }
    
    // MARK: - Logic & Actions
    
    private func incrementProgress() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            habit.increment()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    private func decrementProgress() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            habit.decrement()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    // MARK: - Computed Statistics
    
    private var perfectCountLabel: String {
        switch habit.frequencyUnit {
        case .daily: return "Perfect Days"
        case .weekly: return "Perfect Weeks"
        case .monthly: return "Perfect Months"
        }
    }
    
    private var perfectCount: Int {
        let history = habit.completionHistory
        let goal = habit.frequencyCount
        
        switch habit.frequencyUnit {
        case .daily:
            // Count days where value >= goal
            return history.values.filter { $0 >= goal }.count
            
        case .weekly:
            // Aggregate daily counts into weeks
            var weeklySums: [String: Int] = [:] // Key: "Year-Week"
            let calendar = Calendar.current
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            for (dateStr, count) in history {
                if let date = formatter.date(from: dateStr) {
                    let year = calendar.component(.yearForWeekOfYear, from: date)
                    let week = calendar.component(.weekOfYear, from: date)
                    let key = "\(year)-\(week)"
                    weeklySums[key, default: 0] += count
                }
            }
            return weeklySums.values.filter { $0 >= goal }.count
            
        case .monthly:
            // Aggregate daily counts into months
            var monthlySums: [String: Int] = [:] // Key: "Year-Month"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            for (dateStr, count) in history {
                if let date = formatter.date(from: dateStr) {
                    let comps = Calendar.current.dateComponents([.year, .month], from: date)
                    let key = "\(comps.year!)-\(comps.month!)"
                    monthlySums[key, default: 0] += count
                }
            }
            return monthlySums.values.filter { $0 >= goal }.count
        }
    }
    
    private var completionRateString: String {
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate total units elapsed since creation
        var totalElapsedUnits: Int = 1
        
        switch habit.frequencyUnit {
        case .daily:
            // Days elapsed (minimum 1 to avoid division by zero)
            if let days = calendar.dateComponents([.day], from: habit.dateCreated, to: now).day {
                totalElapsedUnits = max(1, days + 1)
            }
        case .weekly:
            // Weeks elapsed
            if let weeks = calendar.dateComponents([.weekOfYear], from: habit.dateCreated, to: now).weekOfYear {
                totalElapsedUnits = max(1, weeks + 1)
            }
        case .monthly:
            // Months elapsed
            if let months = calendar.dateComponents([.month], from: habit.dateCreated, to: now).month {
                totalElapsedUnits = max(1, months + 1)
            }
        }
        
        let rate = Double(perfectCount) / Double(totalElapsedUnits)
        let percentage = Int(rate * 100)
        return "\(percentage)%"
    }
}

// MARK: - Helper View for Statistics
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color.gradient)
                    .padding(10)
                    .background(color.opacity(0.2))
                    .clipShape(Circle())
                
                Spacer()
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .textCase(.uppercase)
                .fontWeight(.medium)
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, configurations: config)

    let habi = Habit(title: "LeetCode", frequencyCount: 2, frequencyUnit: .daily)
    
//    // 1. Log Today as Completed (Value matches or exceeds frequencyCount)
//    let todayKey = Date().formatted(.iso8601.year().month().day())
//    habi.completionHistory[todayKey] = 2

    // 2. Log Yesterday as Partially Done
    let calendar = Calendar.current
    if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) {
        let yesterdayKey = yesterday.formatted(.iso8601.year().month().day())
        habi.completionHistory[yesterdayKey] = 0
    }
    
    container.mainContext.insert(habi)

    return Text("Parent View")
        .sheet(isPresented: .constant(true)) {
            HabitInfoView(habit: habi)
        }
        .modelContainer(container)
}
