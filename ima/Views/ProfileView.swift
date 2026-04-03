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
    @Environment(\.appBackground) private var appBackground

    // MARK: - Data Queries
    @Query private var tasks: [UserTask]
    @Query private var habits: [Habit]

    // State for Settings Sheet
    @State private var showSettings = false

    // MARK: - Computed Stats

    private var totalHabitCompletions: Int {
        habits.reduce(0) { $0 + $1.totalCount }
    }

    private var totalTasksCompleted: Int {
        tasks.filter { $0.isCompleted }.count
    }

    private var activeDays: Int {
        var dates = Set<String>()
        for habit in habits {
            for (date, count) in habit.completionHistory where count > 0 {
                dates.insert(date)
            }
        }
        return dates.count
    }

    private var currentStreak: Int {
        let dailyHabits = habits.filter { $0.frequencyUnit == .daily }
        guard !dailyHabits.isEmpty else { return 0 }

        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current

        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // If today isn't fully done yet, start counting from yesterday
        let todayKey = formatter.string(from: checkDate)
        let todayDone = dailyHabits.allSatisfy {
            ($0.completionHistory[todayKey] ?? 0) >= $0.frequencyCount
        }

        if !todayDone {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = yesterday
        }

        while true {
            let key = formatter.string(from: checkDate)
            // Only check habits that existed on this date
            let relevant = dailyHabits.filter {
                calendar.startOfDay(for: $0.dateCreated) <= checkDate
            }
            guard !relevant.isEmpty else { break }

            let allDone = relevant.allSatisfy {
                ($0.completionHistory[key] ?? 0) >= $0.frequencyCount
            }

            if allDone {
                streak += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = prev
            } else {
                break
            }
        }

        return streak
    }

    private var strongestHabits: [Habit] {
        habits.sorted { completionRate(for: $0) > completionRate(for: $1) }.prefix(3).map { $0 }
    }

    private var weakestHabits: [Habit] {
        habits.sorted { completionRate(for: $0) < completionRate(for: $1) }.prefix(3).map { $0 }
    }

    private func completionRate(for habit: Habit) -> Double {
        let calendar = Calendar.current
        let now = Date()
        let goal = habit.frequencyCount
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current

        // Count perfect cycles
        var perfectCount: Int
        switch habit.frequencyUnit {
        case .daily:
            perfectCount = habit.completionHistory.values.filter { $0 >= goal }.count
        case .weekly:
            var weeklyMax: [String: Int] = [:]
            for (dateStr, count) in habit.completionHistory {
                if let date = formatter.date(from: dateStr) {
                    let y = calendar.component(.yearForWeekOfYear, from: date)
                    let w = calendar.component(.weekOfYear, from: date)
                    let key = "\(y)-W\(w)"
                    weeklyMax[key] = max(weeklyMax[key] ?? 0, count)
                }
            }
            perfectCount = weeklyMax.values.filter { $0 >= goal }.count
        case .monthly:
            var monthlyMax: [String: Int] = [:]
            for (dateStr, count) in habit.completionHistory {
                if let date = formatter.date(from: dateStr) {
                    let comps = calendar.dateComponents([.year, .month], from: date)
                    let key = "\(comps.year!)-M\(comps.month!)"
                    monthlyMax[key] = max(monthlyMax[key] ?? 0, count)
                }
            }
            perfectCount = monthlyMax.values.filter { $0 >= goal }.count
        }

        // Elapsed cycles
        let elapsed: Int
        switch habit.frequencyUnit {
        case .daily:
            elapsed = max(1, (calendar.dateComponents([.day], from: habit.dateCreated, to: now).day ?? 0) + 1)
        case .weekly:
            elapsed = max(1, (calendar.dateComponents([.weekOfYear], from: habit.dateCreated, to: now).weekOfYear ?? 0) + 1)
        case .monthly:
            elapsed = max(1, (calendar.dateComponents([.month], from: habit.dateCreated, to: now).month ?? 0) + 1)
        }

        return Double(perfectCount) / Double(elapsed)
    }

    // Grid layout
    private let statColumns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        ZStack {
            appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {

                    // MARK: - Top Nav
                    HStack {
                        Button { showSettings = true } label: {
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
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                                .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)

                            Text("LA")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }

                        VStack(spacing: 8) {
                            Text("Lloyd Alba")
                                .font(.title2)
                                .foregroundStyle(.white)

                            Text("CS Student")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }

                    // MARK: - Overview Stats
                    VStack(alignment: .leading, spacing: 10) {
                        Text("OVERVIEW")
                            .font(.caption2)
                            .textCase(.uppercase)
                            .kerning(1.0)
                            .opacity(0.5)
                            .foregroundStyle(.white)

                        LazyVGrid(columns: statColumns, spacing: 8) {
                            ProfileStatCard(title: "Completions", value: "\(totalHabitCompletions)")
                            ProfileStatCard(title: "Tasks Done", value: "\(totalTasksCompleted)")
                            ProfileStatCard(title: "Day Streak", value: "\(currentStreak)")
                            ProfileStatCard(title: "Active Days", value: "\(activeDays)")
                        }
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
                                ForEach(Array(strongestHabits.enumerated()), id: \.element.id) { index, habit in
                                    HabitStatRow(
                                        rank: index + 1,
                                        habit: habit,
                                        rate: completionRate(for: habit),
                                        type: .strong
                                    )
                                }
                            }
                        }
                    }

                    // MARK: - Needs Improvement
                    if !weakestHabits.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("NEEDS IMPROVEMENT")
                                .font(.caption2)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)

                            VStack(spacing: 8) {
                                ForEach(Array(weakestHabits.enumerated()), id: \.element.id) { index, habit in
                                    HabitStatRow(
                                        rank: index + 1,
                                        habit: habit,
                                        rate: completionRate(for: habit),
                                        type: .weak
                                    )
                                }
                            }
                        }
                    }

                    Color.clear.frame(height: 50)
                }
                .padding(.horizontal, 25)
            }
            .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

// MARK: - Profile Stat Card

struct ProfileStatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial.opacity(0.1))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        }
    }
}

// MARK: - Habit Stat Row

enum StatType {
    case strong, weak

    var color: Color {
        switch self {
        case .strong: return .green
        case .weak: return .red
        }
    }
}

struct HabitStatRow: View {
    let rank: Int
    let habit: Habit
    let rate: Double
    let type: StatType

    var body: some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(type.color.opacity(0.8))
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(habit.title)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text("\(Int(rate * 100))% completion rate")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer()

            Text("\(Int(rate * 100))%")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(type.color.opacity(0.8))
        }
        .padding(15)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial.opacity(0.1))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        }
    }
}

#Preview {
    ProfileView()
}
