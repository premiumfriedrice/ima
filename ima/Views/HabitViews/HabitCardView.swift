//
//  HabitCardView.swift
//  ima/Views/HabitViews
//
//  Created by Lloyd Derryk Mudanza Alba on 12/23/25.
//

import SwiftUI
import SwiftData

struct HabitCardView: View {
    @Bindable var habit: Habit // Use Bindable for SwiftData objects
    @State private var showingEditSheet: Bool = false // Renamed for clarity
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            // MARK: - Layer 1: The Main Card (Opens Detail Sheet)
            VStack(alignment: .leading, spacing: 10) {
                // Title Row
                HStack {
                    Text(habit.title)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    // Info button removed from here to separate touch targets
                }
                
                // Subtitle with tracking
                Text("\(habit.currentCount)/\(habit.frequencyCount) \(timePeriodString)")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .kerning(1.0)
                    .opacity(0.5)
                    .foregroundStyle(.white)

                // Refined Progress Bar
                SegmentedProgressBar(
                    value: habit.currentCount,
                    total: habit.frequencyCount,
                    color: habit.statusColor
                )
                .frame(height: 8)
                .shadow(color: habit.statusColor.opacity(0.3), radius: 4, x: 0, y: 2)
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
                                habit.statusColor.opacity(0.6),
                                habit.statusColor.opacity(0.1),
                                habit.statusColor.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
            .opacity(habit.isFullyDone ? 0.4 : 1.0)
            .scaleEffect(habit.isFullyDone ? 0.98 : 1.0)
            .padding(.horizontal, 20)
            // MARK: - Interaction & Accessibility (Main Card)
            .onTapGesture {
                // CHANGE: Card tap now opens the sheet
                showingEditSheet = true
            }
            .accessibilityIdentifier("HabitCard_\(habit.title)")
            .accessibilityAddTraits(.isButton)
            .accessibilityValue(habit.isFullyDone ? "Done" : "\(habit.currentCount) out of \(habit.frequencyCount) \(timePeriodString)")

            
            // MARK: - Layer 2: The Increment Button (Floating on Top)
            // CHANGE: This button now Increments instead of showing info
            Button(action: { incrementHabit() }) {
                Image(systemName: "plus") // CHANGE: Icon to Plus
                    .font(.system(size: 18, weight: .bold)) // Slightly larger for tap target
                    .foregroundColor(habit.isFullyDone ? habit.statusColor.opacity(0.4) : habit.statusColor)
                    .padding(8)
                    .background(habit.statusColor.opacity(0.15))
                    .clipShape(Circle())
            }
            // Add padding to position it correctly relative to the card
            // 20 (outer padding) + 20 (inner card padding) = 40 roughly, adjusted for visual balance
            .padding(.top, 20)
            .padding(.trailing, 40)
            .accessibilityIdentifier("IncrementButton")
        }
        .sheet(isPresented: $showingEditSheet) {
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
        case .daily:
            return "today"
        case .weekly:
            return "this week"
        case .monthly:
            return "this month"
        }
    }
}

#Preview {
    let habi = Habit(title: "Habi", frequencyCount: 2, frequencyUnit: .daily)
    
    ZStack{
        Color.black.ignoresSafeArea()
        HabitCardView(habit: habi)
    }
}
