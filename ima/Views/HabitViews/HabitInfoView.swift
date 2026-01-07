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
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: - Swipe Pill
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 10)
                
                // MARK: - Header
                HStack {
                    // Edit Button
                    Button {
                        withAnimation(.snappy) { isEditing.toggle() }
                    } label: {
                        Image(systemName: isEditing ? "checkmark" : "square.and.pencil")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(isEditing ? .black : .white.opacity(0.6))
                            .padding(12)
                            .background(isEditing ? .white : .white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    // Reset Button
                    Button { showingResetConfirmation = true } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(12)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Delete Button
                    Button(role: .destructive) { showingDeleteConfirmation = true } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.red.opacity(0.8))
                            .padding(12)
                            .background(.red.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 10)
                .padding(.top, 10)
               
                ScrollView {
                    VStack(spacing: 32) {
                       
                        // MARK: - Hero Title
                        VStack(alignment: .leading, spacing: 12) {
                            Text("HABIT")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            Text(habit.title)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)
                       
                        // MARK: - Today's Progress (Circular)
                        VStack(alignment: .leading, spacing: 25) {
                            Text("TODAY'S PROGRESS")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                           
                            HStack(spacing: 30) {
                                Button { decrementProgress() } label: {
                                    Image(systemName: "minus")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 50, height: 50)
                                        .background(.white.opacity(0.1))
                                        .clipShape(Circle())
                                }

                                ZStack {
                                    // 1. Background Track
                                    Circle()
                                        .stroke(Color.white.opacity(0.1), lineWidth: 15)
                                   
                                    // 2. Progress Indicator
                                    Circle()
                                        .trim(from: 0, to: CGFloat(habit.progress))
                                        .stroke(
                                            habit.statusColor,
                                            style: StrokeStyle(lineWidth: 15, lineCap: .round)
                                        )
                                        .rotationEffect(.degrees(-90))
                                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: habit.currentCount)
                                        .opacity(habit.currentCount > 0 ? 1.0 : 0.0)
                                   
                                    // 3. Text Inside
                                    VStack(spacing: 0) {
                                        Text("\(habit.currentCount)")
                                            .font(.system(size: 48, weight: .black, design: .rounded))
                                            .foregroundStyle(.white)
                                            .contentTransition(.numericText(value: Double(habit.currentCount)))
                                        
                                        Text("/ \(habit.frequencyCount)")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundStyle(.white.opacity(0.5))
                                    }
                                }
                                
                                Button { incrementProgress() } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.black)
                                        .padding(12)
                                        .background(.white)
                                        .clipShape(Circle())
                                        .shadow(color: .white.opacity(0.2), radius: 10, x: 0, y: 0)
                                }
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
                                    .fontWeight(.bold)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)
                               
                                HStack(spacing: 0) {
                                    // Rolling Count
                                    Picker("Count", selection: $habit.frequencyCount) {
                                        ForEach(1...50, id: \.self) { number in
                                            Text("\(number)")
                                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                                .foregroundStyle(.white)
                                                .tag(number)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(width: 72, height: 128)
                                    .compositingGroup()
                                   
                                    Text(habit.frequencyCount == 1 ? "time per" : "times per")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.4))
                                        .padding(.horizontal, 8)
                                   
                                    // Rolling Frequency
                                    Picker("Frequency", selection: $habit.frequencyUnitRaw) {
                                        ForEach(FrequencyUnit.allCases, id: \.self) { unit in
                                            Text(unit.rawValue.capitalized)
                                                .font(.system(size: 28, weight: .bold, design: .rounded))
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
                        }
                       
                        Spacer()
                       
                        Text("Created " + habit.dateCreated.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .textCase(.uppercase)
                            .kerning(1.0)
                            .opacity(0.5)
                            .foregroundStyle(.white)
                            .padding(.bottom, 20)
                    }
                    .padding(.top, 20)
                }
            }
            .foregroundStyle(.white)
            .overlay {
                RoundedRectangle(cornerRadius: 40)
                    .stroke(LinearGradient(stops: [.init(color: .white.opacity(0.2), location: 0.0), .init(color: .white.opacity(0.05), location: 0.2), .init(color: .clear, location: 0.5)], startPoint: .top, endPoint: .bottom), lineWidth: 1.5)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        // MARK: - Presentation Logic
        .presentationDetents([.medium, .large]) // 1. Allows Halfway + Full Screen
        .presentationDragIndicator(.hidden)     // 2. Hide system pill (we made our own)
        .presentationBackground(.ultraThinMaterial.opacity(0.1))         // 3. Remove system background so our Black ZStack shows
        .presentationCornerRadius(40)           // 4. Match the corner radius of our design
        
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
        withAnimation(.spring(response: 0.3, dampingFraction: 12)) {
            habit.increment()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    private func decrementProgress() {
        withAnimation(.spring(response: 0.3, dampingFraction: 1)) {
            habit.decrement()
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
