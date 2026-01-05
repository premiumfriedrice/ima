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
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            AnimatedRadial(color: .white.opacity(0.1), startPoint: .topLeading, endPoint: .topTrailing)
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(12)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .accessibilityIdentifier("CloseInfoViewButton")
                    
                    Spacer()
                    
                    Button {
                        showingResetConfirmation = true
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(12)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.red.opacity(0.8))
                            .padding(12)
                            .background(.red.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(25)
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // MARK: - Hero Title (Static)
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
                        
                        // MARK: - Today's Progress
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TODAY'S PROGRESS")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            HStack(spacing: 20) {
                                // 1. Decrement Button
                                Button {
                                    decrementProgress()
                                } label: {
                                    Image(systemName: "minus")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 60, height: 60)
                                        .background(.white.opacity(0.1))
                                        .clipShape(Circle())
                                }
                                
                                // 2. Main Counter (Big)
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    // Current Count - REMOVED $
                                    Text("\(habit.currentCount)")
                                        .font(.system(size: 64, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                        .contentTransition(.numericText(value: Double(habit.currentCount)))
                                    
                                    // Target - REMOVED $
                                    Text("/ \(habit.frequencyCount)")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                .frame(maxWidth: .infinity)
                                
                                // 3. Increment Button (Prominent)
                                Button {
                                    incrementProgress()
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(.black)
                                        .frame(width: 60, height: 60)
                                        .background(.white)
                                        .clipShape(Circle())
                                        .shadow(color: .white.opacity(0.2), radius: 10, x: 0, y: 0)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        .padding(.horizontal, 25)
                        
                        // MARK: - Adjust Goal
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
                        lineWidth: 1.5
                    )
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
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
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, configurations: config)
    
    let habi = Habit(title: "LeetCode", frequencyCount: 2, frequencyUnit: .daily)
    container.mainContext.insert(habi)
    
    return HabitInfoView(habit: habi)
        .modelContainer(container)
}
