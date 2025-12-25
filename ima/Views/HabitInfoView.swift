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
            AnimatedRadial(color: .white.opacity(0.1), startPoint: .topLeading, endPoint: .topTrailing)
            
            VStack(spacing: 0) {
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
                .padding(.bottom, 20)
                
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

                        // MARK: - Adjust Your Goal (Rolling Style)
                        VStack(alignment: .leading, spacing: 15) {
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
                                            .tag(unit.rawValue) // Whats the difference between unit and unit.rawValue?
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 136, height: 128)
                                .compositingGroup()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 25)
                        
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
            
        }
    }
}
