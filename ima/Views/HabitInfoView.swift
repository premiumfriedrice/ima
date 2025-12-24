//
//  HabitInfoView.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/23/25.
//

import SwiftUI
import SwiftData

struct HabitInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var habit: Habit
    
    // Grid setup for the 7-day calendar rows
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 35) {
                // MARK: - Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(habit.title)
                            .font(.title.bold())
                        Text("Consistency History")
                            .font(.caption).opacity(0.5)
                    }
                    Spacer()
                    Button("Done") { dismiss() }
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                }
                .padding(.horizontal, 25)
                .padding(.top, 30)

                // MARK: - Contribution Calendar
                VStack(alignment: .leading, spacing: 12) {
                    
                    let config = ModelConfiguration(isStoredInMemoryOnly: true)
                    let container = try! ModelContainer(for: Habit.self, configurations: config)
                    
                    CalendarView(habit: habit)
                        .modelContainer(container)
                }
                .padding(.horizontal, 25)

                // MARK: - Frequency Logic (The Sentence Builder)
                VStack(alignment: .leading, spacing: 15) {
                    Text("ADJUST GOAL")
                        .font(.caption2).bold().opacity(0.4)
                    
                    VStack(spacing: 1) {
                        HStack {
                            Text("Perform this")
                            Spacer()
                            Stepper("\(habit.frequencyCount) times", value: $habit.frequencyCount, in: 1...100)
                                .fontWeight(.semibold)
                                .foregroundStyle(.blue)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 15, topTrailingRadius: 15))
                        
                        HStack {
                            Text("every")
                            Spacer()
                            Picker("Frequency", selection: $habit.frequencyUnitRaw) {
                                ForEach(FrequencyUnit.allCases, id: \.self) { unit in
                                    Text(unit.rawValue).tag(unit.rawValue)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.blue)
                            .fontWeight(.bold)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 15, bottomTrailingRadius: 15))
                    }
                }
                .padding(.horizontal, 25)

                Spacer()
                
                // MARK: - Delete
                Button(role: .destructive) {
                    modelContext.delete(habit)
                    dismiss()
                } label: {
                    Text("Delete Habit")
                        .font(.subheadline).bold()
                        .foregroundStyle(.red.opacity(0.7))
                }
                .padding(.bottom, 40)
            }
            .foregroundStyle(.white)
        }
    }
}
