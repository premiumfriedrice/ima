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
                        HStack(spacing: 6) {
                            Text("CREATE")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                            Image(systemName: "arrow.up")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(!title.isEmpty ? .black : .white.opacity(0.3))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(!title.isEmpty ? .white : .white.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    .disabled(title.isEmpty)
                    .accessibilityIdentifier("SaveHabitButton")

                }
                .padding(25)

                ScrollView {
                    VStack(spacing: 32) {
                        
                        // MARK: - Title Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("NEW HABIT")
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
                                .accessibilityIdentifier("HabitTitleInput")
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
