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
    
    // 1. Add state to control the sheet size
    @State private var currentDetent: PresentationDetent = .medium
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
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
                            // If we are entering edit mode, force the sheet to expand
                            if isEditing {
                                currentDetent = .large
                            }
                        }
                    } label: {
                        Image(systemName: isEditing ? "checkmark" : "square.and.pencil")
                            .font(.callout)
                            .foregroundStyle(isEditing ? .white : .white.opacity(0.6))
                            .padding(10)
                            .background(
                                ZStack {
                                    if isEditing {
                                        // Gradient when active
                                        LinearGradient(
                                            colors: [Color.blue, Color.purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    } else {
                                        // Subtle gray background when disabled
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
                
                // 2. Wrap ScrollView in ScrollViewReader to enable scrolling
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
                            
                            // MARK: - Today's Progress (Responsive)
                            VStack(alignment: .leading, spacing: 10) {
                                Text("TODAY'S PROGRESS")
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)
                                
                                HStack(spacing: 20) {
                                    // 1. Decrement Button
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
                                        let size = min(geo.size.width, geo.size.height)
                                        
                                        ProgressRingWithDots(habit: habit, fillFactor: 0.9) {
                                            VStack(spacing: 0) {
                                                // Scale font relative to the size to keep proportions
                                                Text("\(habit.currentCount)")
                                                    .font(.system(size: size * 0.2, weight: .black, design: .rounded))
                                                    .foregroundStyle(.white)
                                                    .contentTransition(.numericText(value: Double(habit.currentCount)))
                                                
                                                Text("/ \(habit.frequencyCount)")
                                                    .font(.system(size: size * 0.1, weight: .bold, design: .rounded))
                                                    .foregroundStyle(.white.opacity(0.5))
                                            }
                                        }
                                    }
                                    .frame(height: 250)
                                    
                                    // 3. Increment Button
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
                            
                            // MARK: - Adjust Goal
                            if isEditing {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("ADJUST YOUR GOAL")
                                        .font(.system(.caption, design: .rounded))
//                                        .fontWeight(.bold)
                                        .textCase(.uppercase)
                                        .kerning(1.0)
                                        .opacity(0.5)
                                        .foregroundStyle(.white)
                                    
                                    HStack(spacing: 0) {
                                        // Rolling Count
                                        Picker("Count", selection: $habit.frequencyCount) {
                                            ForEach(1...50, id: \.self) { number in
                                                Text("\(number)")
                                                    .font(.system(size: 28, /*weight: .bold,*/ design: .rounded))
                                                    .foregroundStyle(.white)
                                                    .tag(number)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 72, height: 128)
                                        .compositingGroup()
                                        
                                        Text(habit.frequencyCount == 1 ? "time per" : "times per")
                                            .font(.system(size: 28, /*weight: .bold,*/ design: .rounded))
                                            .foregroundStyle(.white.opacity(0.4))
                                            .padding(.horizontal, 8)
                                        
                                        // Rolling Frequency
                                        Picker("Frequency", selection: $habit.frequencyUnitRaw) {
                                            ForEach(FrequencyUnit.allCases, id: \.self) { unit in
                                                Text(unit.rawValue.capitalized)
                                                    .font(.system(size: 28, /*weight: .bold,*/ design: .rounded))
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
                                // 3. Add an ID so we can scroll to it
                                .id("AdjustGoalSection")
                            }
                            
                            Spacer()
                            
                            Text("Created " + habit.dateCreated.formatted(date: .abbreviated, time: .shortened))
                                .font(.system(.caption, design: .rounded))
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                                .padding(.bottom, 20)
                        }
                        .padding(.top, 20)
                    }
                    // 4. Watch for edit state changes to trigger scroll
                    .onChange(of: isEditing) { _, newValue in
                        if newValue {
                            // Delay slightly to allow the sheet to expand to .large before scrolling
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    proxy.scrollTo("AdjustGoalSection", anchor: .center)
                                }
                            }
                        }
                    }
                }
            }
        }
        .foregroundStyle(.white)
        .overlay {
            RoundedRectangle(cornerRadius: 40)
                .stroke(LinearGradient(stops: [.init(color: .white.opacity(0.2), location: 0.0), .init(color: .white.opacity(0.05), location: 0.2), .init(color: .clear, location: 0.5)], startPoint: .top, endPoint: .bottom), lineWidth: 1.5)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        // MARK: - Presentation Logic
        // 5. Bind the detents to the state variable
        .presentationDetents([.medium, .large], selection: $currentDetent)
        .presentationDragIndicator(.hidden)
        .presentationBackground(.ultraThinMaterial.opacity(0.1))
        .presentationCornerRadius(40)
        
        // MARK: - Alerts
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
                dismiss()
                withAnimation {
                    habit.resetCurrentProgress()
                }
            }
            Button("Cancel") { }
        } message: {
            Text("This action will reset progress for this habit for today.")
        }
    }
    
    // MARK: - Logic
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
