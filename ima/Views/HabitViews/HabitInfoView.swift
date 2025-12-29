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

                                // Dimmed Connector Text
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
                        
                        Text(habit.dateCreated.formatted(date: .abbreviated, time: .standard))
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .textCase(.uppercase)
                            .kerning(1.0)
                            .opacity(0.5)
                            .foregroundStyle(.white)
                        
//                        // MARK: - Calendar History
//                        VStack(alignment: .leading, spacing: 15) {
//                            CalendarView(habit: habit)
//                        }
//                        .padding(.horizontal, 25)
                    }
                    .padding(.top, 20)
                }
            }
            .foregroundStyle(.white)
            .overlay {
                    RoundedRectangle(cornerRadius: 40) // Matches standard iOS sheet corners
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(0.2), location: 0.0), // Shiny top
                                    .init(color: .white.opacity(0.05), location: 0.2), // Fades quickly
                                    .init(color: .clear, location: 0.5) // Invisible at bottom
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                        .ignoresSafeArea() // Ensures the stroke follows the sheet edge completely
                        .allowsHitTesting(false) // Ensures you can still touch buttons underneath
                }
            
        }
        .confirmationDialog(
            "Are you sure you want to delete '\(habit.title)'?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Habit", role: .destructive) {
                // 1. Dismiss FIRST to trigger the slide-down animation
                dismiss()
                
                // 2. Wait for the animation to finish before destroying the data
                Task {
                    try? await Task.sleep(for: .seconds(0.35)) // Standard sheet animation time
                    modelContext.delete(habit)
                }
            }
            Button("Cancel") { }
        } message: {
            Text("This action cannot be undone.")
        }
        .confirmationDialog(
                    "Are you sure you want to delete '\(habit.title)'?",
                    isPresented: $showingDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete Habit", role: .destructive) {
                        dismiss()
                        modelContext.delete(habit)
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
    
}

#Preview {
    let habi = Habit(title: "LeetCode", frequencyCount: 2, frequencyUnit: .daily)
    HabitInfoView(habit: habi)
}
