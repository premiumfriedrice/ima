//
//  HistoryHeatmap.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 1/4/26.
//

import SwiftUI
import SwiftData

struct HistoryHeatmap: View {
    @Bindable var habit: Habit
    
    // MARK: - Calendar Logic
    private let calendar = Calendar.current
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    var body: some View {
        // MARK: - History (Yearly Heatmap)
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("HISTORY")
                    .font(.system(.caption, design: .rounded))
                    .textCase(.uppercase)
                    .kerning(1.0)
                    .opacity(0.5)
                    .foregroundStyle(.white)
                
                Spacer()
                
                // Legend
                Text("Less")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.3))
                HStack(spacing: 2) {
                    ForEach(1...4, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.green.opacity(Double(i) * 0.25))
                            .frame(width: 8, height: 8)
                    }
                }
                Text("More")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.3))
            }
            
            // Container for Fixed Axis + Scrollable Grid
            HStack(alignment: .top, spacing: 8) {
                
                // 1. Fixed Day Labels (Vertical Axis)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(0..<7, id: \.self) { index in
                        // Show Mon, Wed, Fri (Index 1, 3, 5)
                        if [1, 3, 5].contains(index) {
                            Text(calendar.weekdaySymbols[index].prefix(1)) // "M", "W", "F"
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.3))
                                .frame(height: 12)
                        } else {
                            // Empty spacer to maintain vertical alignment with grid rows
                            Spacer().frame(height: 12)
                        }
                    }
                }
                
                // 2. The Scrollable Heatmap Grid
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(
                            rows: Array(repeating: GridItem(.fixed(12), spacing: 4), count: 7),
                            spacing: 4
                        ) {
                            ForEach(heatmapDates, id: \.self) { date in
                                if let date = date {
                                    let intensity = getOpacityFor(date: date)
                                    let isToday = calendar.isDateInToday(date)
                                    
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(
                                            intensity > 0
                                            ? .green.opacity(intensity)
                                            : .white.opacity(0.06)
                                        )
                                        .frame(width: 12, height: 12)
                                        .overlay {
                                            if isToday {
                                                RoundedRectangle(cornerRadius: 2)
                                                    .stroke(.white, lineWidth: 1)
                                            }
                                        }
                                        .id(date)
                                } else {
                                    // Placeholder for alignment
                                    Color.clear
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                        .frame(height: (12 * 7) + (4 * 6)) // Matches height of the label stack
                    }
                    .onAppear {
                        // Scroll to today
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if let today = heatmapDates.first(where: { $0 != nil && calendar.isDateInToday($0!) }) {
                                withAnimation {
                                    scrollProxy.scrollTo(today, anchor: .center)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 25)
    }
    
    // MARK: - Logic
    
    private func getOpacityFor(date: Date) -> Double {
        switch habit.frequencyUnit {
        case .daily:
            // Standard: Current Day Count / Daily Goal
            let key = formatter.string(from: date)
            let count = Double(habit.completionHistory[key] ?? 0)
            if count == 0 { return 0 }
            
            let target = Double(habit.frequencyCount)
            return max(0.3, min(1.0, count / target))
            
        case .weekly:
            // Weekly: Total for the whole week / Weekly Goal
            let weekTotal = getWeekTotal(for: date)
            if weekTotal == 0 { return 0 }
            
            let target = Double(habit.frequencyCount)
            return max(0.3, min(1.0, Double(weekTotal) / target))
            
        case .monthly:
            // Monthly: Total for the whole month / Monthly Goal
            let monthTotal = getMonthTotal(for: date)
            if monthTotal == 0 { return 0 }
            
            let target = Double(habit.frequencyCount)
            return max(0.3, min(1.0, Double(monthTotal) / target))
        }
    }
    
    // Helper to sum counts for the week surrounding the date
    private func getWeekTotal(for date: Date) -> Int {
        // Find start and end of week
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else { return 0 }
        
        var total = 0
        var current = weekInterval.start
        
        // Loop through week
        while current < weekInterval.end {
            let key = formatter.string(from: current)
            total += habit.completionHistory[key] ?? 0
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return total
    }
    
    // Helper to sum counts for the month surrounding the date
    private func getMonthTotal(for date: Date) -> Int {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return 0 }
        
        var total = 0
        var current = monthInterval.start
        
        while current < monthInterval.end {
            let key = formatter.string(from: current)
            total += habit.completionHistory[key] ?? 0
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return total
    }
    
    // Generates dates for the current year
    private var heatmapDates: [Date?] {
        let year = calendar.component(.year, from: Date())
        guard let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
              let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31)) else {
            return []
        }
        
        let weekday = calendar.component(.weekday, from: startOfYear) // 1=Sun...
        let offset = weekday - 1
        
        let daysInYear = calendar.dateComponents([.day], from: startOfYear, to: endOfYear).day! + 1
        let dates = (0..<daysInYear).compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day, to: startOfYear)
        }
        
        let emptySlots = Array(repeating: nil as Date?, count: offset)
        return emptySlots + dates
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, configurations: config)
    
    // Test Case: Weekly Habit (Goal: 3x per week)
    let habit = Habit(title: "Gym", frequencyCount: 3, frequencyUnit: .weekly)
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = .current
    
    // Simulate activity:
    // Week 1 (Current week): 3 times (100% opacity)
    // Week 2 (Last week): 1 time (33% opacity)
    for i in 0..<7 {
        // Current week activity
        if let date = calendar.date(byAdding: .day, value: -i, to: Date()), i % 2 == 0 {
             let key = formatter.string(from: date)
             habit.completionHistory[key] = 1
        }
    }
    
    // Last week activity (Just one day)
    if let lastWeekDate = calendar.date(byAdding: .day, value: -10, to: Date()) {
        let key = formatter.string(from: lastWeekDate)
        habit.completionHistory[key] = 1
    }
    
    container.mainContext.insert(habit)
    
    return ZStack {
        Color.black.ignoresSafeArea()
        HistoryHeatmap(habit: habit)
    }
    .modelContainer(container)
}
