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
    @Environment(\.appBackground) private var appBackground

    @State private var title: String = ""
    @State private var isGoalHabit: Bool = false
    @State private var frequencyCount: Int = 1
    @State private var frequencyUnit: FrequencyUnit = .daily
    @State private var goalTarget: Int = 30
    @State private var targetRate: Int = 80

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - Swipe Pill
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)

                // MARK: - Header
                HStack {
                    Spacer()

                    Button { saveHabit() } label: {
                        Image(systemName: "checkmark")
                            .font(.title3)
                            .foregroundStyle(!title.isEmpty ? .white : .white.opacity(0.3))
                            .padding(10)
                            .background(
                                ZStack {
                                    if !title.isEmpty {
                                        LinearGradient(
                                            colors: [Color.blue, Color.purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    } else {
                                        Color.white.opacity(0.1)
                                    }
                                }
                            )
                            .clipShape(Circle())
                            .shadow(color: !title.isEmpty ? Color.blue.opacity(0.5) : .clear, radius: 10, x: 0, y: 5)
                            .animation(.smooth, value: !title.isEmpty)
                    }
                    .disabled(title.isEmpty)
                    .accessibilityIdentifier("SaveHabitButton")
                }
                .padding(.horizontal, 20)

                ScrollView {
                    VStack(spacing: 28) {

                        // MARK: - Title
                        VStack(alignment: .leading, spacing: 10) {
                            Text("HABIT")
                                .font(.caption2)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)

                            TextField("e.g., Read, Meditate...", text: $title)
                                .font(.title)
                                .tint(.blue)
                                .autocorrectionDisabled()
                                .accessibilityIdentifier("HabitTitleInput")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)

                        // MARK: - Type Toggle
                        VStack(alignment: .leading, spacing: 10) {
                            Text("TYPE")
                                .font(.caption2)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)

                            HStack(spacing: 10) {
                                TypeOption(
                                    label: "Perpetual",
                                    caption: "Track with a target rate",
                                    isSelected: !isGoalHabit
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        isGoalHabit = false
                                    }
                                }

                                TypeOption(
                                    label: "Goal",
                                    caption: "Reach a set number",
                                    isSelected: isGoalHabit
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        isGoalHabit = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 25)

                        // MARK: - Frequency
                        VStack(alignment: .leading, spacing: 10) {
                            Text("FREQUENCY")
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

                                Text(frequencyCount == 1 ? "time per" : "times per")
                                    .font(.title3)
                                    .foregroundStyle(.white.opacity(0.4))

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

                        // MARK: - Type-Specific Target
                        if isGoalHabit {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("TARGET")
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)

                                HStack(spacing: 0) {
                                    Picker("Goal", selection: $goalTarget) {
                                        ForEach(1...365, id: \.self) { n in
                                            Text("\(n)")
                                                .font(.title)
                                                .foregroundStyle(.white)
                                                .tag(n)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(width: 80, height: 96)
                                    .compositingGroup()

                                    Text(goalTarget == 1 ? "perfect \(cycleSingular)" : "perfect \(cyclePlural)")
                                        .font(.title3)
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 25)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        } else {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("MINIMUM RATE")
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)

                                HStack(spacing: 0) {
                                    Picker("Rate", selection: $targetRate) {
                                        ForEach([50, 60, 70, 80, 90, 100], id: \.self) { rate in
                                            Text("\(rate)%")
                                                .font(.title)
                                                .foregroundStyle(.white)
                                                .tag(rate)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(width: 100, height: 96)
                                    .compositingGroup()

                                    Text("completion target")
                                        .font(.title3)
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 25)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
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
                        lineWidth: 3
                    )
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .presentationBackground(appBackground)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(40)
    }

    // MARK: - Helpers

    private var cycleSingular: String {
        switch frequencyUnit {
        case .daily: return "day"
        case .weekly: return "week"
        case .monthly: return "month"
        }
    }

    private var cyclePlural: String {
        switch frequencyUnit {
        case .daily: return "days"
        case .weekly: return "weeks"
        case .monthly: return "months"
        }
    }

    private func saveHabit() {
        let newHabit = Habit(
            title: title,
            frequencyCount: frequencyCount,
            frequencyUnit: frequencyUnit,
            goalTarget: isGoalHabit ? goalTarget : 0,
            targetRate: isGoalHabit ? 0 : targetRate
        )
        modelContext.insert(newHabit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}

// MARK: - Type Option Card

private struct TypeOption: View {
    let label: String
    let caption: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.4))

                Text(caption)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .white.opacity(0.5) : .white.opacity(0.25))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial.opacity(isSelected ? 0.15 : 0.05))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white.opacity(isSelected ? 0.2 : 0.08), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CreateHabitView()
}
