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
    @State private var isEditingName = false
    @State private var isEditingTagline = false
    @State private var emojiInput: String = ""
    @FocusState private var isEmojiFocused: Bool

    // Profile data
    @AppStorage("profileEmoji") private var profileEmoji: String = "🎯"
    @AppStorage("profileName") private var profileName: String = ""
    @AppStorage("profileTagline") private var profileTagline: String = ""

    // MARK: - Habit Stats

    private var perpetualHabits: [Habit] {
        habits.filter { $0.isPerpetual }
    }

    private var challengeHabits: [Habit] {
        habits.filter { $0.isChallengeHabit }
    }

    private var overallCompletionRate: Int {
        let rates = perpetualHabits.map { completionRate(for: $0) }
        guard !rates.isEmpty else { return 0 }
        return Int(rates.reduce(0, +) / Double(rates.count) * 100)
    }

    private var goalsReached: Int {
        challengeHabits.filter { habit in
            let perfect = perfectCount(for: habit)
            return perfect >= habit.goalTarget
        }.count
    }

    private var currentStreak: Int {
        let dailyHabits = perpetualHabits.filter { $0.frequencyUnit == .daily }
        guard !dailyHabits.isEmpty else { return 0 }

        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current

        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

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

    private var closestChallengeHabit: Habit? {
        challengeHabits
            .filter { perfectCount(for: $0) < $0.goalTarget }
            .max { a, b in
                Double(perfectCount(for: a)) / Double(a.goalTarget) <
                Double(perfectCount(for: b)) / Double(b.goalTarget)
            }
    }

    private var strongestHabits: [Habit] {
        perpetualHabits
            .sorted { completionRate(for: $0) > completionRate(for: $1) }
            .prefix(3)
            .map { $0 }
    }

    private var achievedChallengeHabits: [Habit] {
        challengeHabits.filter { perfectCount(for: $0) >= $0.goalTarget }
    }

    // MARK: - Task Stats

    private var tasksCompleted: Int {
        tasks.filter { $0.isCompleted }.count
    }

    private var tasksPending: Int {
        tasks.filter { !$0.isCompleted }.count
    }

    private var tasksOverdue: Int {
        let now = Calendar.current.startOfDay(for: Date())
        return tasks.filter { task in
            !task.isCompleted && task.dueDate != nil && Calendar.current.startOfDay(for: task.dueDate!) < now
        }.count
    }

    private var subtasksDone: Int {
        tasks.flatMap { $0.subtasks }.filter { $0.isCompleted }.count
    }

    // MARK: - Helpers

    private func completionRate(for habit: Habit) -> Double {
        let calendar = Calendar.current
        let now = Date()
        let goal = habit.frequencyCount
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current

        let perfect = perfectCount(for: habit)

        let elapsed: Int
        switch habit.frequencyUnit {
        case .daily:
            elapsed = max(1, (calendar.dateComponents([.day], from: habit.dateCreated, to: now).day ?? 0) + 1)
        case .weekly:
            elapsed = max(1, (calendar.dateComponents([.weekOfYear], from: habit.dateCreated, to: now).weekOfYear ?? 0) + 1)
        case .monthly:
            elapsed = max(1, (calendar.dateComponents([.month], from: habit.dateCreated, to: now).month ?? 0) + 1)
        }

        return Double(perfect) / Double(elapsed)
    }

    private func perfectCount(for habit: Habit) -> Int {
        let goal = habit.frequencyCount
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        let calendar = Calendar.current

        switch habit.frequencyUnit {
        case .daily:
            return habit.completionHistory.values.filter { $0 >= goal }.count
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
            return weeklyMax.values.filter { $0 >= goal }.count
        case .monthly:
            var monthlyMax: [String: Int] = [:]
            for (dateStr, count) in habit.completionHistory {
                if let date = formatter.date(from: dateStr) {
                    let comps = calendar.dateComponents([.year, .month], from: date)
                    let key = "\(comps.year!)-M\(comps.month!)"
                    monthlyMax[key] = max(monthlyMax[key] ?? 0, count)
                }
            }
            return monthlyMax.values.filter { $0 >= goal }.count
        }
    }

    private var personalityTitle: String {
        if currentStreak >= 7 { return "Streak Warrior" }
        if overallCompletionRate >= 90 { return "Habit Machine" }
        if challengeHabits.count > perpetualHabits.count { return "Challenge Hunter" }
        if tasksCompleted > 20 { return "Task Crusher" }
        if habits.count >= 5 { return "The Dedicated" }
        if habits.count > 0 || tasks.count > 0 { return "On the Rise" }
        return "Getting Started"
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
                                .font(.callout)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(10)
                                .background(.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.top, 20)

                    // MARK: - Profile Hero
                    VStack(spacing: 16) {
                        // Emoji Avatar
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            isEmojiFocused
                                                ? AnyShapeStyle(LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                                                : AnyShapeStyle(Color.white.opacity(0.15)),
                                            lineWidth: isEmojiFocused ? 2 : 1
                                        )
                                )

                            TextField("", text: $emojiInput)
                                .font(.system(size: 40))
                                .multilineTextAlignment(.center)
                                .focused($isEmojiFocused)
                                .frame(width: 60, height: 60)
                                .tint(.clear)
                                .onChange(of: emojiInput) { _, newValue in
                                    let emojis = newValue.filter { $0.isEmoji }
                                    if let last = emojis.last {
                                        profileEmoji = String(last)
                                        emojiInput = String(last)
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        isEmojiFocused = false
                                    } else if newValue.isEmpty {
                                        emojiInput = profileEmoji
                                    } else {
                                        emojiInput = profileEmoji
                                    }
                                }
                        }
                        .onTapGesture {
                            emojiInput = profileEmoji
                            isEmojiFocused = true
                        }
                        .onAppear {
                            emojiInput = profileEmoji
                        }

                        // Personality title
                        Text(personalityTitle.uppercased())
                            .font(.caption2)
                            .textCase(.uppercase)
                            .kerning(1.0)
                            .foregroundStyle(.white.opacity(0.4))

                        // Editable name
                        VStack(spacing: 6) {
                            if isEditingName {
                                TextField("Your Name", text: $profileName)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .submitLabel(.done)
                                    .onSubmit { isEditingName = false }
                            } else {
                                Text(profileName.isEmpty ? "Your Name" : profileName)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(profileName.isEmpty ? .white.opacity(0.3) : .white)
                                    .onTapGesture { isEditingName = true }
                            }

                            // Editable tagline
                            if isEditingTagline {
                                TextField("Add a tagline...", text: $profileTagline)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .submitLabel(.done)
                                    .onSubmit { isEditingTagline = false }
                            } else {
                                Text(profileTagline.isEmpty ? "Add a tagline..." : profileTagline)
                                    .font(.subheadline)
                                    .foregroundStyle(profileTagline.isEmpty ? .white.opacity(0.25) : .white.opacity(0.5))
                                    .onTapGesture { isEditingTagline = true }
                            }
                        }

                        // Streak badge
                        if currentStreak > 0 {
                            HStack(spacing: 4) {
                                Text("🔥")
                                    .font(.caption)
                                Text("\(currentStreak) day streak")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.orange)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background {
                                Capsule()
                                    .fill(.orange.opacity(0.1))
                            }
                            .overlay {
                                Capsule()
                                    .stroke(.orange.opacity(0.2), lineWidth: 1)
                            }
                        }
                    }

                    // MARK: - HABITS
                    VStack(alignment: .leading, spacing: 10) {
                        Text("HABITS")
                            .font(.caption2)
                            .textCase(.uppercase)
                            .kerning(1.0)
                            .opacity(0.5)
                            .foregroundStyle(.white)

                        LazyVGrid(columns: statColumns, spacing: 8) {
                            // Completion Rate
                            ProfileStatCard(title: "Completion Rate", value: "\(overallCompletionRate)%") {
                                ProfileStatDetailShell(
                                    icon: "chart.bar.fill",
                                    title: "Completion Rate",

                                    color: .green,
                                    description: "Average percentage of cycles where you met your goal across all perpetual habits."
                                ) {
                                    Text("\(overallCompletionRate)%")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundStyle(.green.gradient)

                                    VStack(spacing: 10) {
                                        ForEach(Array(perpetualHabits.enumerated()), id: \.element.id) { index, habit in
                                            let rate = completionRate(for: habit)
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    Text(habit.title)
                                                        .font(.caption)
                                                        .foregroundStyle(.white.opacity(0.7))
                                                        .lineLimit(1)

                                                    Spacer()

                                                    Text("\(Int(rate * 100))%")
                                                        .font(.caption)
                                                        .foregroundStyle(.white.opacity(0.5))
                                                }

                                                AnimatedBar(
                                                    progress: rate,
                                                    color: .green,
                                                    delay: 0.3 + Double(index) * 0.08
                                                )
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }

                            // Goals Reached
                            ProfileStatCard(title: "Challenges Won", value: "\(goalsReached)") {
                                ProfileStatDetailShell(
                                    icon: "target",
                                    title: "Challenges Won",

                                    color: .blue,
                                    description: "Challenge habits where you've completed the required number of perfect cycles."
                                ) {
                                    Text("\(goalsReached) of \(challengeHabits.count)")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundStyle(.blue)

                                    VStack(spacing: 8) {
                                        ForEach(challengeHabits) { habit in
                                            let progress = perfectCount(for: habit)
                                            let done = progress >= habit.goalTarget
                                            HStack(spacing: 10) {
                                                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                                                    .foregroundStyle(done ? AnyShapeStyle(.green.gradient) : AnyShapeStyle(.white.opacity(0.3)))
                                                    .font(.subheadline)

                                                Text(habit.title)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.white.opacity(done ? 0.5 : 0.8))
                                                    .lineLimit(1)

                                                Spacer()

                                                Text("\(progress)/\(habit.goalTarget)")
                                                    .font(.caption)
                                                    .foregroundStyle(.white.opacity(0.4))
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }

                            // Current Streak
                            ProfileStatCard(title: "Current Streak", value: "\(currentStreak)") {
                                ProfileStatDetailShell(
                                    icon: "flame.fill",
                                    title: "Current Streak",

                                    color: .orange,
                                    description: "Consecutive days where all perpetual daily habits were fully completed."
                                ) {
                                    Text("\(currentStreak)")
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundStyle(.orange)
                                }
                            }

                            // Total Tracked
                            ProfileStatCard(title: "Total Tracked", value: "\(habits.count)") {
                                ProfileStatDetailShell(
                                    icon: "list.bullet",
                                    title: "Total Tracked",

                                    color: .white,
                                    description: "Total habits you're tracking, including both perpetual and goal types."
                                ) {
                                    Text("\(habits.count)")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundStyle(.white)

                                    HStack(spacing: 12) {
                                        VStack(spacing: 6) {
                                            Text("\(perpetualHabits.count)")
                                                .font(.title2.bold())
                                                .foregroundStyle(.green.gradient)
                                            Text("Perpetual")
                                                .font(.caption2)
                                                .foregroundStyle(.white.opacity(0.5))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(.green.gradient.opacity(0.1))
                                        }

                                        VStack(spacing: 6) {
                                            Text("\(challengeHabits.count)")
                                                .font(.title2.bold())
                                                .foregroundStyle(.blue)
                                            Text("Challenge")
                                                .font(.caption2)
                                                .foregroundStyle(.white.opacity(0.5))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(.blue.opacity(0.1))
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }

                        // Strongest Perpetual
                        if let top = strongestHabits.first {
                            ProfileStatCard(title: "Strongest Perpetual", value: top.title, subtitle: "\(Int(completionRate(for: top) * 100))%") {
                                ProfileStatDetailShell(
                                    icon: "crown.fill",
                                    title: "Strongest Perpetual",

                                    color: .green,
                                    description: "Your most consistent perpetual habit by completion rate."
                                ) {
                                    Text("\(Int(completionRate(for: top) * 100))%")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundStyle(.green.gradient)

                                    Text(top.title)
                                        .font(.title3)
                                        .foregroundStyle(.white)

                                    AnimatedBar(
                                        progress: completionRate(for: top),
                                        color: .green,
                                        height: 8,
                                        delay: 0.35
                                    )
                                    .padding(.horizontal, 40)
                                }
                            }
                        }

                        // Closest Goal
                        if let closest = closestChallengeHabit {
                            let progress = perfectCount(for: closest)
                            ProfileStatCard(title: "Closest Challenge", value: closest.title, subtitle: "\(progress)/\(closest.goalTarget)") {
                                ProfileStatDetailShell(
                                    icon: "flag.fill",
                                    title: "Closest Challenge",
                                    color: .blue,
                                    description: "The goal habit nearest to completion."
                                ) {
                                    Text("\(progress) / \(closest.goalTarget)")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundStyle(.blue)

                                    Text(closest.title)
                                        .font(.title3)
                                        .foregroundStyle(.white)

                                    VStack(spacing: 8) {
                                        AnimatedBar(
                                            progress: Double(progress) / Double(closest.goalTarget),
                                            color: .blue,
                                            height: 8,
                                            delay: 0.35
                                        )

                                        let remaining = closest.goalTarget - progress
                                        Text("\(remaining) more to go")
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.5))
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }

                    // MARK: - TASKS
                    VStack(alignment: .leading, spacing: 10) {
                        Text("TASKS")
                            .font(.caption2)
                            .textCase(.uppercase)
                            .kerning(1.0)
                            .opacity(0.5)
                            .foregroundStyle(.white)

                        LazyVGrid(columns: statColumns, spacing: 8) {
                            // Pending
                            ProfileStatCard(title: "Pending", value: "\(tasksPending)") {
                                ProfileStatDetailShell(
                                    icon: "clock.fill",
                                    title: "Pending",

                                    color: .yellow,
                                    description: "Tasks that haven't been completed yet."
                                ) {
                                    Text("\(tasksPending)")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundStyle(.yellow)

                                    VStack(spacing: 8) {
                                        ForEach(tasks.filter { !$0.isCompleted }.prefix(5)) { task in
                                            HStack(spacing: 10) {
                                                Circle()
                                                    .fill(task.priority.color)
                                                    .frame(width: 8, height: 8)
                                                Text(task.title)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.white.opacity(0.8))
                                                    .lineLimit(1)
                                                Spacer()
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }

                            // Completed
                            ProfileStatCard(title: "Completed", value: "\(tasksCompleted)") {
                                ProfileStatDetailShell(
                                    icon: "checkmark.circle.fill",
                                    title: "Completed",

                                    color: .green,
                                    description: "Total number of tasks you've marked as complete."
                                ) {
                                    Text("\(tasksCompleted)")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundStyle(.green.gradient)

                                    let total = tasks.count
                                    if total > 0 {
                                        VStack(spacing: 8) {
                                            AnimatedBar(
                                                progress: Double(tasksCompleted) / Double(total),
                                                color: .green,
                                                height: 8,
                                                delay: 0.35
                                            )

                                            Text("\(tasksCompleted) of \(total) tasks")
                                                .font(.caption)
                                                .foregroundStyle(.white.opacity(0.5))
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }

                            // Overdue
                            ProfileStatCard(title: "Overdue", value: "\(tasksOverdue)") {
                                let now = Calendar.current.startOfDay(for: Date())
                                let overdueTasks = tasks.filter { task in
                                    !task.isCompleted && task.dueDate != nil && Calendar.current.startOfDay(for: task.dueDate!) < now
                                }
                                ProfileStatDetailShell(
                                    icon: "exclamationmark.triangle.fill",
                                    title: "Overdue",

                                    color: .red,
                                    description: "Incomplete tasks whose due date has passed."
                                ) {
                                    Text("\(tasksOverdue)")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundStyle(.red)

                                    VStack(spacing: 8) {
                                        ForEach(overdueTasks.prefix(5)) { task in
                                            let days = Calendar.current.dateComponents([.day], from: task.dueDate!, to: Date()).day ?? 0
                                            HStack(spacing: 10) {
                                                Text(task.title)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.white.opacity(0.8))
                                                    .lineLimit(1)
                                                Spacer()
                                                Text("\(days)d overdue")
                                                    .font(.caption2)
                                                    .foregroundStyle(.red.opacity(0.8))
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }

                            // Subtasks Done
                            ProfileStatCard(title: "Subtasks Done", value: "\(subtasksDone)") {
                                let totalSubs = tasks.flatMap { $0.subtasks }.count
                                ProfileStatDetailShell(
                                    icon: "checklist",
                                    title: "Subtasks Done",

                                    color: .purple,
                                    description: "Total subtasks completed across all tasks."
                                ) {
                                    Text("\(subtasksDone)")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundStyle(.purple)

                                    if totalSubs > 0 {
                                        VStack(spacing: 8) {
                                            AnimatedBar(
                                                progress: Double(subtasksDone) / Double(totalSubs),
                                                color: .purple,
                                                height: 8,
                                                delay: 0.35
                                            )

                                            Text("\(subtasksDone) of \(totalSubs) subtasks")
                                                .font(.caption)
                                                .foregroundStyle(.white.opacity(0.5))
                                        }
                                        .padding(.horizontal, 20)
                                    }
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
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

// MARK: - Emoji Picker


extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}

// MARK: - Profile Stat Card

struct ProfileStatCard<Detail: View>: View {
    let title: String
    let value: String
    var subtitle: String = ""
    @ViewBuilder var detail: () -> Detail

    @State private var showingDetail = false

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            showingDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(value)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        if !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }

                    Spacer()

                    Image(systemName: "info.circle")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.25))
                }

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
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDetail) {
            detail()
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
                .foregroundStyle(type.color.gradient.opacity(0.8))
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
                .foregroundStyle(type.color.gradient.opacity(0.8))
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
