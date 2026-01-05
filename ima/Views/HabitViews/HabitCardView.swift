//
//  HabitCardView.swift
//  ima/Views/HabitViews
//
//  Created by Lloyd Derryk Mudanza Alba on 12/23/25.
//

import SwiftUI
import SwiftData

struct HabitCardView: View {
    @Bindable var habit: Habit
    @State private var showingInfoSheet: Bool = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            // MARK: - Layer 1: The Main Card
            VStack(alignment: .leading, spacing: 10) {
                // Title Row
                HStack(spacing: 12) {
                    Text(habit.title)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Spacer()
                }
                
                // Subtitle Row (Count & Frequency)
                Text("\(habit.currentCount)/\(habit.frequencyCount) \(timePeriodString)")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .kerning(1.0)
                    .opacity(0.5)
                    .foregroundStyle(.white)
                
                // Progress Line (Bottom)
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Track
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 4)
                        
                        // Indicator
                        Capsule()
                            .fill(Color.green) // Habits are Green
                            .frame(width: CGFloat(min(habit.progress, 1.0)) * geometry.size.width, height: 4)
                            .shadow(color: Color.green.opacity(0.5), radius: 4, x: 0, y: 2)
                    }
                }
                .frame(height: 4)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: habit.currentCount)
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial.opacity(0.1))
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.black.opacity(0.4))
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .green.opacity(0.6),
                                .green.opacity(0.1),
                                .green.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
            // Visual feedback when completed
            .opacity(habit.isFullyDone ? 0.6 : 1.0)
            .scaleEffect(habit.isFullyDone ? 0.98 : 1.0)
            .padding(.horizontal, 20)
            
            // MARK: - Interaction (Tap to Increment)
            .onTapGesture {
                showingInfoSheet = true
            }
            
            // Right Side: Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: CGFloat(habit.progress))
                    .stroke(
                        .white,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: habit.currentCount)

                Button(action: { incrementHabit() }) {
                    Image(systemName: habit.isFullyDone ? "checkmark" : "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(habit.isFullyDone ? .black : .white)
                        .frame(width: 32, height: 32)
                        .background(habit.isFullyDone ? .white : .clear)
                        .clipShape(Circle())
                }
                .accessibilityIdentifier("IncrementButton")
            }
            .frame(width: 44, height: 44)
            .padding(.top, 15)
            .padding(.trailing, 35)
        }
        .sheet(isPresented: $showingInfoSheet) {
            HabitInfoView(habit: habit)
        }
    }

    private func incrementHabit() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            habit.increment()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    private var timePeriodString: String {
        switch habit.frequencyUnit {
        case .daily: return "TODAY"
        case .weekly: return "THIS WEEK"
        case .monthly: return "THIS MONTH"
        }
    }
}

#Preview {
    let habi = Habit(title: "Meditate", frequencyCount: 3, frequencyUnit: .daily)
    habi.currentCount = 1
    
    return ZStack {
        Color.black.ignoresSafeArea()
        HabitCardView(habit: habi)
    }
}
