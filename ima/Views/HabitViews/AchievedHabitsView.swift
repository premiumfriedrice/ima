//
//  AchievedHabitsView.swift
//  ima/Views/HabitViews
//
//  Showcase of goal habits that reached their target.
//

import SwiftUI

struct AchievedHabitsView: View {
    let habits: [Habit]
    @Environment(\.appBackground) private var appBackground
    @State private var selectedHabit: Habit?

    var body: some View {
        ZStack {
            appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    Text("HABITS")
                        .font(.caption2)
                        .textCase(.uppercase)
                        .kerning(1.0)
                        .opacity(0.5)
                        .foregroundStyle(.white)

                    Text("Achieved")
                        .font(.title)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 25)
                .padding(.top, 12)
                .padding(.bottom, 16)

                if habits.isEmpty {
                    Spacer()
                    Text("No achieved goals yet")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.3))
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(habits) { habit in
                                HabitCardView(habit: habit)
                                    .onTapGesture { selectedHabit = habit }
                            }

                            Color.clear.frame(height: 100)
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .toolbarBackground(appBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(item: $selectedHabit) { habit in
            HabitInfoView(habit: habit)
        }
    }
}
