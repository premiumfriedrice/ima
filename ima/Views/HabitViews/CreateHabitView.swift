//
//  CreateHabitView.swift
//  ima/Views/HabitViews
//
//  Created by Lloyd Derryk Mudanza Alba on 12/24/25.
//

import SwiftUI
import SwiftData

struct CreateHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title: String = ""
    @State private var frequencyCount: Int = 1
    @State private var frequencyUnit: FrequencyUnit = .daily
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - Swipe Pill
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 20)
                
                // MARK: - Header
                HStack {
                    Spacer()
                    
                    // Create Button (Checkmark)
                    Button {
                        saveHabit()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.title3)
                            .foregroundStyle(!title.isEmpty ? .white : .white.opacity(0.3))
                            .padding(10)
                            .background(
                                ZStack {
                                    if !title.isEmpty {
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
                            // Add a glow when active
                            .shadow(color: !title.isEmpty ? Color.blue.opacity(0.5) : .clear, radius: 10, x: 0, y: 5)
                            .animation(.smooth, value: !title.isEmpty)
                    }
                    .disabled(title.isEmpty)
                    .accessibilityIdentifier("SaveHabitButton")

                }
                .padding(.horizontal, 20)

                ScrollView {
                    VStack(spacing: 32) {
                        
                        // MARK: - Title Input
                        VStack(alignment: .leading, spacing: 10) {
                            Text("HABIT")
                                .font(.caption2)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            TextField("e.g., Read, Meditate...", text: $title)
                                .font(.title2)
                                .tint(.blue)
                                .autocorrectionDisabled()
                                .accessibilityIdentifier("HabitTitleInput")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading) // Pushes text to the left
                        .padding(.horizontal, 25)
                        
                        // MARK: - Set Goal
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SET YOUR GOAL")
                                .font(.caption2)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            HStack(spacing: 0) {
                                Picker("Count", selection: $frequencyCount) {
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

                                // Dimmed Connector Text
                                Text(frequencyCount == 1 ? "time per" : "times per")
                                    .font(.title)
                                    .foregroundStyle(.white.opacity(0.4))
                                
                                // Rolling Frequency
                                Picker("Frequency", selection: $frequencyUnit) {
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
                                .init(color: .white.opacity(0.2), location: 0.0),  // Exact match to InfoView
                                .init(color: .white.opacity(0.05), location: 0.2),
                                .init(color: .clear, location: 0.5)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 3 // Thicker line catches more "light"
                    )
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        // MARK: - Sheet Configuration
        .presentationBackground(.ultraThickMaterial.opacity(0.5))
        .presentationDetents([.medium]) // Locks sheet to half height
        .presentationDragIndicator(.hidden)
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
    CreateHabitView()
}
