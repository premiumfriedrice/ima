//
//  HistoryHeatmap.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 1/4/26.
//

import SwiftUI
import SwiftData

struct HistoryHeatmap : View {
    @Bindable var habit: Habit
    
    // MARK: - Calendar Logic
    private let calendar = Calendar.current
    
    var body: some View {
        // MARK: - History (Yearly Heatmap)
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("HISTORY")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .kerning(1.0)
                    .opacity(0.5)
                    .foregroundStyle(.white)
                
                Spacer()
                
                // Optional: Legend
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
            
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // 1. Day Labels Column (Mon, Wed, Fri)
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(0..<7, id: \.self) { index in
                                if [1, 3, 5].contains(index) { // Mon, Wed, Fri
                                    Text(calendar.weekdaySymbols[index].prefix(3))
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.3))
                                        .frame(height: 12)
                                } else {
                                    Spacer().frame(height: 12)
                                }
                            }
                        }
                        .padding(.top, 20) // Push down to align with grid (below month labels)
                        
                        // 2. The Heatmap Grid
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
                                        .id(date) // Tag for scrolling
                                } else {
                                    // Empty placeholder for alignment
                                    Color.clear
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                        .frame(height: (12 * 7) + (4 * 6)) // Fixed height for 7 rows
                    }
                    .padding(.horizontal, 4)
                }
                .onAppear {
                    // Scroll to today with a slight delay to ensure layout is ready
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let today = heatmapDates.first(where: { $0 != nil && calendar.isDateInToday($0!) }) {
                            withAnimation {
                                scrollProxy.scrollTo(today, anchor: .center)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .background(.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 25)
    }
    
    // Calculates opacity based on how close current count is to the goal
    // 0 = Transparent (handled in view)
    // 1...Goal = Scales from 0.3 to 1.0 opacity
    private func getOpacityFor(date: Date) -> Double {
        // MATCH THE MODEL'S KEY LOGIC
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        let key = formatter.string(from: date)
        
        let count = habit.completionHistory[key] ?? 0
        
        if count == 0 { return 0 }
        
        let target = Double(habit.frequencyCount)
        let current = Double(count)
        
        return max(0.3, min(1.0, current / target))
    }
    
// Generates dates for the current year (Jan 1 - Dec 31), padded to start on Sunday
    private var heatmapDates: [Date?] {
        let year = calendar.component(.year, from: Date())
        guard let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
              let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31)) else {
            return []
        }
        
        // 1. Calculate start offset (if Jan 1 is Wednesday, we need 3 empty slots: Sun, Mon, Tue)
        let weekday = calendar.component(.weekday, from: startOfYear) // 1=Sun, 2=Mon...
        let offset = weekday - 1
        
        // 2. Generate actual days
        let daysInYear = calendar.dateComponents([.day], from: startOfYear, to: endOfYear).day! + 1
        let dates = (0..<daysInYear).compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day, to: startOfYear)
        }
        
        // 3. Combine empty slots + dates
        let emptySlots = Array(repeating: nil as Date?, count: offset)
        return emptySlots + dates
    }
}
