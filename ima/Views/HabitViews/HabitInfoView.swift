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
    @Environment(\.appBackground) private var appBackground
    @Bindable var habit: Habit
    var readOnly: Bool = false
    var displayDate: Date? = nil

    private var displayCount: Int {
        guard let date = displayDate else { return habit.currentCount }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return habit.completionHistory[formatter.string(from: date)] ?? 0
    }

    @State private var showingDeleteConfirmation = false
    @State private var showingResetConfirmation = false
    @State private var isEditing = false
    @State private var animatedRate: Double = 0
    @State private var currentDetent: PresentationDetent = .medium
    
    // Grid layout for statistics
    private let statColumns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // MARK: - Swipe Pill
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                
                // MARK: - Header
                Group {
                    if readOnly {
                        Color.clear.frame(height: 0)
                    } else if isEditing {
                        HStack {
                            Text("EDITING")
                                .font(.caption2)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .foregroundStyle(.white.opacity(0.4))

                            Spacer()

                            Button {
                                withAnimation(.snappy) {
                                    isEditing = false
                                    currentDetent = .medium
                                }
                            } label: {
                                Image(systemName: "checkmark")
                                    .font(.callout)
                                    .foregroundStyle(.white)
                                    .padding(10)
                                    .background(
                                        LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                    } else {
                        HStack {
                            Button { showingResetConfirmation = true } label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.callout)
                                    .foregroundStyle(.white.opacity(0.6))
                                    .padding(10)
                                    .background(.white.opacity(0.1))
                                    .clipShape(Circle())
                            }

                            Spacer()

                            Button {
                                withAnimation(.snappy) {
                                    isEditing = true
                                    currentDetent = .large
                                }
                            } label: {
                                Image(systemName: "square.and.pencil")
                                    .font(.callout)
                                    .foregroundStyle(.white.opacity(0.6))
                                    .padding(10)
                                    .background(.white.opacity(0.1))
                                    .clipShape(Circle())
                            }

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
                        .padding(.bottom, 8)
                    }
                }
                .background {
                    appBackground.ignoresSafeArea()
                }
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        colors: [appBackground, .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 12)
                    .offset(y: 12)
                }
                .zIndex(1)

                ScrollView {
                    VStack(spacing: 32) {
                        // MARK: - Hero Title
                        VStack(alignment: .leading, spacing: 10) {
                            Text(habit.isChallengeHabit ? "CHALLENGE HABIT" : "PERPETUAL HABIT")
                                .font(.caption2)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)

                            if isEditing {
                                TextField("Habit name", text: $habit.title, axis: .vertical)
                                    .font(.title)
                                    .foregroundStyle(.white)
                                    .tint(.blue)
                                    .lineLimit(1...3)
                                    .submitLabel(.done)
                                    .onChange(of: habit.title) { _, newValue in
                                        if newValue.contains("\n") {
                                            habit.title = newValue.replacingOccurrences(of: "\n", with: "")
                                            dismissKeyboard()
                                        }
                                    }
                            } else {
                                Text(habit.title)
                                    .font(.title)
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)

                        if !isEditing {
                            
                            // MARK: - Progress
                            VStack(alignment: .leading, spacing: 10) {
                                Text(progressSectionLabel)
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)

                                HStack {
                                    if !readOnly {
                                        Button { decrementProgress() } label: {
                                            Image(systemName: "minus")
                                                .font(.callout.weight(.semibold))
                                                .foregroundStyle(.white)
                                                .frame(width: 44, height: 44)
                                                .background(.white.opacity(0.1))
                                                .clipShape(Circle())
                                        }
                                    }

                                    Spacer()

                                    ProgressRingWithDots(habit: habit, fillFactor: 0.9, readOnly: readOnly, overrideCount: displayDate != nil ? displayCount : nil) {
                                        VStack(spacing: 0) {
                                            Text("\(displayCount)")
                                                .font(.largeTitle)
                                                .bold()
                                                .foregroundStyle(.white)
                                                .contentTransition(.numericText(value: Double(displayCount)))

                                            Text("/ \(habit.frequencyCount)")
                                                .font(.callout)
                                                .foregroundStyle(.white.opacity(0.5))
                                        }
                                    }
                                    .frame(width: 200, height: 200)

                                    Spacer()

                                    if !readOnly {
                                        Button { incrementProgress() } label: {
                                            Image(systemName: "plus")
                                                .font(.callout.weight(.semibold))
                                                .foregroundStyle(.black)
                                                .frame(width: 44, height: 44)
                                                .background(.white)
                                                .clipShape(Circle())
                                                .shadow(color: .white.opacity(0.15), radius: 8)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 25)
                            .padding(.bottom, 40)

                            // MARK: - History Heatmap
                            HistoryHeatmap(habit: habit)

                            // MARK: - Goal Rate
                            VStack(alignment: .leading, spacing: 10) {
                                Text(habit.isChallengeHabit ? "CHALLENGE PROGRESS" : "COMPLETION RATE")
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)

                                VStack(spacing: 10) {
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(.white.opacity(0.1))

                                            Capsule()
                                                .fill(LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing))
                                                .frame(width: geo.size.width * animatedRate)

                                            // Target marker for ongoing habits
                                            if habit.isPerpetual && habit.targetRate > 0 && habit.targetRate < 100 {
                                                Rectangle()
                                                    .fill(.white.opacity(0.5))
                                                    .frame(width: 2, height: 12)
                                                    .offset(x: geo.size.width * Double(habit.targetRate) / 100.0 - 1)
                                            }
                                        }
                                    }
                                    .frame(height: 6)

                                    HStack {
                                        if habit.isChallengeHabit {
                                            Text("\(perfectCount) / \(habit.goalTarget)")
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                        } else {
                                            Text("\(Int(completionRate * 100))%")
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                        }

                                        Spacer()

                                        if habit.isChallengeHabit {
                                            let remaining = max(0, habit.goalTarget - perfectCount)
                                            Text(remaining == 0 ? "Goal reached" : "\(remaining) \(cycleUnitLabel) to go")
                                                .font(.caption2)
                                                .foregroundStyle(.white.opacity(0.4))
                                        } else {
                                            Text("\(perfectCount) of \(totalElapsedCycles) \(cycleUnitLabel) · \(habit.targetRate)% target")
                                                .font(.caption2)
                                                .foregroundStyle(.white.opacity(0.4))
                                        }
                                    }
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
                            .padding(.horizontal, 25)
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                                    animatedRate = goalBarProgress
                                }
                            }
                            .onChange(of: habit.currentCount) {
                                withAnimation(.easeOut(duration: 0.4)) {
                                    animatedRate = goalBarProgress
                                }
                            }

                            // MARK: - Statistics Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("STATISTICS")
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)
                                
                                LazyVGrid(columns: statColumns, spacing: 8) {
                                    StatCard(
                                        title: perfectCountLabel,
                                        value: "\(perfectCount)",
                                        description: "Number of \(cycleUnitLabel) where you fully met your goal."
                                    )
                                    StatCard(
                                        title: "Current Streak",
                                        value: "\(currentStreak)",
                                        description: "Consecutive \(cycleUnitLabel) where you hit your goal, counting back from now."
                                    )
                                    StatCard(
                                        title: "Best Streak",
                                        value: "\(bestStreak)",
                                        description: "Longest consecutive run of perfect \(cycleUnitLabel) ever recorded."
                                    )
                                    StatCard(
                                        title: "Total Completions",
                                        value: "\(habit.totalCount)",
                                        description: "Lifetime number of times you've incremented this habit."
                                    )
                                }
                            }
                            .padding(.horizontal, 25)

                            Spacer()

                            Text("Created " + habit.dateCreated.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                                .padding(.bottom, 20)

                        } else {
                            // MARK: - Edit Mode Content (matches CreateHabitView)

                            // Type
                            VStack(alignment: .leading, spacing: 10) {
                                Text("TYPE")
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)

                                HStack(spacing: 10) {
                                    EditTypeOption(
                                        label: "Perpetual",
                                        caption: "Track with a target rate",
                                        isSelected: habit.isPerpetual
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            habit.goalTarget = 0
                                            if habit.targetRate == 0 { habit.targetRate = 80 }
                                        }
                                    }

                                    EditTypeOption(
                                        label: "Challenge",
                                        caption: "Reach a set number",
                                        isSelected: habit.isChallengeHabit
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            if habit.goalTarget == 0 { habit.goalTarget = 30 }
                                            habit.targetRate = 0
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 25)

                            // Frequency
                            VStack(alignment: .leading, spacing: 10) {
                                Text("FREQUENCY")
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)

                                HStack(spacing: 0) {
                                    Picker("Count", selection: $habit.frequencyCount) {
                                        ForEach(1...50, id: \.self) { number in
                                            Text("\(number)")
                                                .font(.title)
                                                .foregroundStyle(.white)
                                                .tag(number)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(width: 72, height: 96)
                                    .compositingGroup()

                                    Text(habit.frequencyCount == 1 ? "time per" : "times per")
                                        .font(.title3)
                                        .foregroundStyle(.white.opacity(0.4))

                                    Picker("Frequency", selection: $habit.frequencyUnitRaw) {
                                        ForEach(FrequencyUnit.allCases, id: \.self) { unit in
                                            Text(unit.rawValue.capitalized)
                                                .font(.title)
                                                .foregroundStyle(.white)
                                                .tag(unit.rawValue)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(width: 136, height: 96)
                                    .compositingGroup()
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 25)

                            // Type-specific target
                            if habit.isChallengeHabit {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("TARGET")
                                        .font(.caption2)
                                        .textCase(.uppercase)
                                        .kerning(1.0)
                                        .opacity(0.5)
                                        .foregroundStyle(.white)

                                    HStack(spacing: 0) {
                                        Picker("Goal", selection: $habit.goalTarget) {
                                            ForEach(1...365, id: \.self) { n in
                                                Text("\(n)")
                                                    .font(.title)
                                                    .foregroundStyle(.white)
                                                    .tag(n)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 80, height: 96)
                                        .compositingGroup()

                                        Text(habit.goalTarget == 1 ? "perfect \(cycleSingularLabel)" : "perfect \(cycleUnitLabel)")
                                            .font(.title3)
                                            .foregroundStyle(.white.opacity(0.4))
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal, 25)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            } else {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("MINIMUM RATE")
                                        .font(.caption2)
                                        .textCase(.uppercase)
                                        .kerning(1.0)
                                        .opacity(0.5)
                                        .foregroundStyle(.white)

                                    HStack(spacing: 0) {
                                        Picker("Rate", selection: $habit.targetRate) {
                                            ForEach([50, 60, 70, 80, 90, 100], id: \.self) { rate in
                                                Text("\(rate)%")
                                                    .font(.title)
                                                    .foregroundStyle(.white)
                                                    .tag(rate)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 100, height: 96)
                                        .compositingGroup()

                                        Text("completion target")
                                            .font(.title3)
                                            .foregroundStyle(.white.opacity(0.4))
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal, 25)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                    }
                    .padding(.top, 20)
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
        .presentationBackground(appBackground)
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
            Button("Reset Progress", role: .destructive) {
                withAnimation { habit.resetCurrentProgress() }
            }
            Button("Cancel") { }
        } message: {
            Text("This will reset progress for the current cycle.")
        }
    }
    
    // MARK: - Logic & Actions
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func incrementProgress() {
        guard !readOnly else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            habit.increment()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    private func decrementProgress() {
        guard !readOnly else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            habit.decrement()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    // MARK: - Computed Statistics

    private var progressSectionLabel: String {
        if let date = displayDate, !Calendar.current.isDateInToday(date) {
            let dayName = date.formatted(.dateTime.weekday(.wide)).uppercased()
            return "\(dayName)'S PROGRESS"
        }
        switch habit.frequencyUnit {
        case .daily: return "TODAY'S PROGRESS"
        case .weekly: return "THIS WEEK'S PROGRESS"
        case .monthly: return "THIS MONTH'S PROGRESS"
        }
    }

    private var perfectCountLabel: String {
        switch habit.frequencyUnit {
        case .daily: return "Perfect Days"
        case .weekly: return "Perfect Weeks"
        case .monthly: return "Perfect Months"
        }
    }

    private var perfectCount: Int {
        let goal = habit.frequencyCount
        let cycleMax = buildCycleMaxMap()
        return cycleMax.values.filter { $0 >= goal }.count
    }

    private var currentStreak: Int {
        let calendar = Calendar.current
        let goal = habit.frequencyCount
        let cycleMax = buildCycleMaxMap()

        var streak = 0
        var checkDate = Date()
        let currentKey = cycleKey(for: checkDate)

        // If current cycle isn't done, start from previous
        if (cycleMax[currentKey] ?? 0) < goal {
            guard let prev = calendar.date(byAdding: cycleComponent, value: -1, to: checkDate) else { return 0 }
            checkDate = prev
        }

        while true {
            let key = cycleKey(for: checkDate)
            if (cycleMax[key] ?? 0) >= goal {
                streak += 1
                guard let prev = calendar.date(byAdding: cycleComponent, value: -1, to: checkDate) else { break }
                checkDate = prev
            } else {
                break
            }
        }
        return streak
    }

    private var bestStreak: Int {
        let calendar = Calendar.current
        let goal = habit.frequencyCount
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current

        let cycleMax = buildCycleMaxMap()

        // Get perfect cycle dates sorted chronologically
        let perfectDates: [Date] = cycleMax
            .filter { $0.value >= goal }
            .compactMap { key, _ in
                // Find any date belonging to this cycle
                habit.completionHistory.keys
                    .compactMap { formatter.date(from: $0) }
                    .first { cycleKey(for: $0) == key }
            }
            .sorted()

        guard !perfectDates.isEmpty else { return 0 }

        var best = 1
        var current = 1

        for i in 1..<perfectDates.count {
            let gap = calendar.dateComponents([cycleCalendarComponent], from: perfectDates[i - 1], to: perfectDates[i])
            let distance = gap.value(for: cycleCalendarComponent) ?? 0
            if distance == 1 {
                current += 1
                best = max(best, current)
            } else if distance > 1 {
                current = 1
            }
            // distance == 0 means same cycle, skip
        }
        return best
    }

    // MARK: - Cycle Helpers

    /// Maps each cycle (day/week/month) to the max completionHistory value in that cycle
    private func buildCycleMaxMap() -> [String: Int] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current

        var maxMap: [String: Int] = [:]
        for (dateStr, count) in habit.completionHistory {
            if let date = formatter.date(from: dateStr) {
                let key = cycleKey(for: date)
                maxMap[key] = max(maxMap[key] ?? 0, count)
            }
        }
        return maxMap
    }

    private func cycleKey(for date: Date) -> String {
        let calendar = Calendar.current
        switch habit.frequencyUnit {
        case .daily:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = .current
            return formatter.string(from: date)
        case .weekly:
            let year = calendar.component(.yearForWeekOfYear, from: date)
            let week = calendar.component(.weekOfYear, from: date)
            return "\(year)-W\(week)"
        case .monthly:
            let comps = calendar.dateComponents([.year, .month], from: date)
            return "\(comps.year!)-M\(comps.month!)"
        }
    }

    private var cycleComponent: Calendar.Component {
        switch habit.frequencyUnit {
        case .daily: return .day
        case .weekly: return .weekOfYear
        case .monthly: return .month
        }
    }

    private var cycleCalendarComponent: Calendar.Component {
        cycleComponent
    }

    // MARK: - Goal Rate

    /// The fill value for the progress bar (0–1)
    private var goalBarProgress: Double {
        if habit.isChallengeHabit {
            guard habit.goalTarget > 0 else { return 0 }
            return min(1.0, Double(perfectCount) / Double(habit.goalTarget))
        } else {
            return completionRate
        }
    }

    private var completionRate: Double {
        guard totalElapsedCycles > 0 else { return 0 }
        return min(1.0, Double(perfectCount) / Double(totalElapsedCycles))
    }

    private var totalElapsedCycles: Int {
        let calendar = Calendar.current
        let now = Date()
        switch habit.frequencyUnit {
        case .daily:
            return max(1, (calendar.dateComponents([.day], from: habit.dateCreated, to: now).day ?? 0) + 1)
        case .weekly:
            return max(1, (calendar.dateComponents([.weekOfYear], from: habit.dateCreated, to: now).weekOfYear ?? 0) + 1)
        case .monthly:
            return max(1, (calendar.dateComponents([.month], from: habit.dateCreated, to: now).month ?? 0) + 1)
        }
    }

    private var cycleUnitLabel: String {
        switch habit.frequencyUnit {
        case .daily: return "days"
        case .weekly: return "weeks"
        case .monthly: return "months"
        }
    }

    private var cycleSingularLabel: String {
        switch habit.frequencyUnit {
        case .daily: return "day"
        case .weekly: return "week"
        case .monthly: return "month"
        }
    }
}

// MARK: - Helper View for Statistics
// MARK: - Edit Type Option Card
private struct EditTypeOption: View {
    let label: String
    let caption: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.4))

                Text(caption)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .white.opacity(0.5) : .white.opacity(0.25))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial.opacity(isSelected ? 0.15 : 0.05))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white.opacity(isSelected ? 0.2 : 0.08), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    var description: String = ""

    @State private var showingInfo = false

    var body: some View {
        Button {
            if !description.isEmpty {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showingInfo = true
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(value)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Spacer()

                    if !description.isEmpty {
                        Image(systemName: "info.circle")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.25))
                    }
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
        .sheet(isPresented: $showingInfo) {
            StatInfoSheet(title: title, value: value, description: description, compact: true)
        }
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
