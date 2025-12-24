//
//  CalendarView.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/24/25.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Bindable var habit: Habit
    private let calendar = Calendar.current
    
    // Grid alignment logic
    private var calendarGridDays: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: .now) else { return [] }
        let firstDayOfMonth = monthInterval.start
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        let padding = Array(repeating: nil as Date?, count: weekday - 1)
        let days = generateDates(inside: monthInterval)
        return padding + days
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                Text(Date.now.formatted(.dateTime.month(.wide).year()).uppercased())
                    .font(.caption).bold()
                    .foregroundStyle(.white.opacity(0.4))
                
                VStack(spacing: 15) {
                    // Weekday Header
                    HStack {
                        ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                            Text(day).font(.caption2).bold().frame(maxWidth: .infinity).opacity(0.3)
                        }
                    }
                    
                    // Calendar Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                        ForEach(0..<calendarGridDays.count, id: \.self) { index in
                            if let date = calendarGridDays[index] {
                                dayCircle(for: date)
                            } else {
                                Color.clear.aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.05)))
            }
            .padding(.leading, 25)
            .padding(.trailing, 25)
        }
        .foregroundStyle(.white)
    }

    @ViewBuilder
    private func dayCircle(for date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        let key = date.formatted(.iso8601.year().month().day())
        let count = habit.completionHistory[key] ?? 0 // Get actual count
        let color = habit.colorFor(date: date)
        
        ZStack {
            Circle()
                .fill(color)
            
            Text("\(day)")
                .font(.system(size: 12, weight: .bold))
                // If count is 0, make text dim. If count > 0, make it bright.
                .foregroundStyle(count == 0 ? .white.opacity(0.3) : .white)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func generateDates(inside interval: DateInterval) -> [Date] {
        var dates: [Date] = []
        var current = interval.start
        while current < interval.end {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return dates
    }
}

// MARK: - PREVIEW WITH MOCK DATA
// Replace your existing #Preview block with this one
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, configurations: config)
    
    // Ensure you use the String value if your init expects a String,
    // or the Enum if you updated the init recently.
    let mockHabit = Habit(
        title: "LeetCode",
        frequencyCount: 2,
        frequencyUnit: .daily // Or "Daily" depending on your Init
    )
    
    // Add mock history using the EXACT same key format as your model's colorFor function
    let todayKey = Date().formatted(.iso8601.year().month().day())
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    let yesterdayKey = yesterday.formatted(.iso8601.year().month().day())
    let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
    let twoDaysAgoKey = twoDaysAgo.formatted(.iso8601.year().month().day())

    
    mockHabit.completionHistory[todayKey] = 2    // Green
    mockHabit.completionHistory[yesterdayKey] = 1 // Orange
    mockHabit.completionHistory[twoDaysAgoKey] = 2 // Green
    
    return CalendarView(habit: mockHabit)
        .modelContainer(container)
}
