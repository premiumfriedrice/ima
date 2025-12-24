//
//  CreateSheetView.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/24/25.
//

import SwiftUI
import SwiftData

struct CreateSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Local state for the new habit details
    @State private var title: String = ""
    @State private var frequencyCount: Int = 1
    @State private var frequencyUnit: FrequencyUnit = .daily
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                // MARK: - Header
                HStack {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button("Create") {
                        saveHabit()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(title.isEmpty ? .gray : .blue)
                    .disabled(title.isEmpty)
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
                
                // MARK: - Title Input (The "Big" Component)
                VStack(alignment: .leading, spacing: 12) {
                    Text("NAME YOUR HABIT")
                        .font(.caption2).bold().opacity(0.4)
                    
                    TextField("e.g., Read, Meditate...", text: $title)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .tint(.blue)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 25)

                // MARK: - Frequency Sentence Builder
                VStack(alignment: .leading, spacing: 15) {
                    Text("SET YOUR GOAL")
                        .font(.caption2).bold().opacity(0.4)
                    
                    VStack(spacing: 1) {
                        // Part 1: Count
                        HStack {
                            Text("Perform this")
                                .font(.headline)
                            Spacer()
                            Stepper("\(frequencyCount) times", value: $frequencyCount, in: 1...100)
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.05))
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                        
                        // Part 2: Unit
                        HStack {
                            Text("every")
                                .font(.headline)
                            Spacer()
                            Picker("Frequency", selection: $frequencyUnit) {
                                ForEach(FrequencyUnit.allCases, id: \.self) { unit in
                                    Text(unit.rawValue).tag(unit)
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

                Spacer()
            }
            .foregroundStyle(.white)
        }
    }
    
    private func saveHabit() {
        let newHabit = Habit(
            title: title,
            frequencyCount: frequencyCount,
            frequencyUnit: frequencyUnit
        )
        modelContext.insert(newHabit)
        
        // Haptic feedback for successful creation
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        dismiss()
    }
}
