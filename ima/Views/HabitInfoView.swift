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
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                // MARK: - Header
                HStack {
                    Button(role: .destructive) {
                        modelContext.delete(habit)
                        dismiss()
                    } label: {
                        Text("Delete")
                            .foregroundStyle(.red)
                    }
                    
                    Spacer()
                    
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 40) {
                        // MARK: - Hero Title (Static)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("HABIT")
                                .font(.caption2).bold().opacity(0.4)
                            Text(habit.title)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)
                        .padding(.top, 1)
                        
                        // MARK: - Frequency Sentence Builder
                        VStack(alignment: .leading, spacing: 15) {
                            Text("ADJUST YOUR GOAL")
                                .font(.caption2).bold().opacity(0.4)
                            
                            VStack(spacing: 1) {
                                HStack {
                                    Stepper("\(habit.frequencyCount) times", value: $habit.frequencyCount, in: 1...100)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.blue)
                                }
                                .padding(20)
                                .background(Color.white.opacity(0.05))
                                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                                
                                HStack {
                                    Text("every")
                                        .font(.headline)
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
                                .padding(20)
                                .background(Color.white.opacity(0.05))
                                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20))
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        // MARK: - Calendar History
                        VStack(alignment: .leading, spacing: 15) {
                            // Ensure your CalendarView is accessible here
                            CalendarView(habit: habit)
                        }
                        .padding(.horizontal, 25)
                        .padding(.bottom, 30)
                    }
                }
            }
            .foregroundStyle(.white)
        }
    }
}
