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
    
    @State private var title: String = ""
    @State private var frequencyCount: Int = 1
    @State private var frequencyUnit: FrequencyUnit = .daily
    
    var body: some View {
        ZStack {
            Color(.black).ignoresSafeArea()
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
                    
                    Spacer()
                    
                    Button {
                        saveHabit()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(title.isEmpty ? .white.opacity(0.2) : .blue)
                            .padding(12)
                            .background(Circle().fill(title.isEmpty ? .white.opacity(0.05) : .blue.opacity(0.1)))
                    }
                    .disabled(title.isEmpty)

                }
                .padding(25)

                ScrollView {
                    VStack(spacing: 32) {
                        
                        // MARK: - Title Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("NAME YOUR HABIT")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            TextField("e.g., Read, Meditate...", text: $title)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .tint(.blue)
                                .autocorrectionDisabled()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading) // Pushes text to the left
                        .padding(.horizontal, 25)
                        
                        // MARK: - Set Goal
                        VStack(alignment: .leading, spacing: 0) {
                            Text("SET YOUR GOAL")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            HStack(spacing: 0) {
                                Picker("Count", selection: $frequencyCount) {
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
                                Text(frequencyCount == 1 ? "time per" : "times per")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.4))
                                    .padding(.horizontal, 8)
                                
                                // Rolling Frequency
                                Picker("Frequency", selection: $frequencyUnit) {
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
                        
                    }
                    .padding(.top, 20)
                }
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
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}

#Preview {
    CreateSheetView()
}
