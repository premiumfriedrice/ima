//
//  HabitGroupView.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/23/25.
//

import SwiftUI
import SwiftData

struct HabitGroupView: View {
    @Environment(\.modelContext) private var modelContext
    var habits: [Habit]
    var onAddTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Habits")
                    .font(.title)
                    .foregroundStyle(.white)
                    .bold()
                    .padding(.leading, 8)
                
                Spacer() // This pushes the button to the far right
                
                Button(action: onAddTap) {
                    Image(systemName: "plus")
                        .font(.title) // Uniform weight
                        .foregroundColor(.white)
                        .bold()
                }
                .padding(.trailing, 16)
            }
            .padding(.horizontal, 16) // Matches the "Today's Work" alignment
            .padding(.bottom, 16)    // Space before the first card
            
            VStack(spacing: 8) {
                ForEach(habits) { habit in
                    HabitCardView(habit: habit)
                }
            }
        }
        .padding(.vertical, 10)
    }
    
    private func deleteHabit(_ habit: Habit) {
        // 1. Remove from the local context
        modelContext.delete(habit)
        
        // 2. Save the change
        try? modelContext.save()
        
        // 3. Optional: Trigger haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
}
