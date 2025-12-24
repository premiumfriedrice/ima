//
//  HabitEditView.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/23/25.
//

import SwiftUI
import SwiftData

struct HabitEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var habit: Habit
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header Area
                HStack {
                    Text("Edit Habit")
                        .font(.title2).bold()
                    Spacer()
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Name Input
                VStack(alignment: .leading, spacing: 10) {
                    Text("NAME").font(.caption).opacity(0.6)
                    TextField("Habit Name", text: $habit.title)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.1)))
                        // This prevents the keyboard from hiding your dark theme
                        .submitLabel(.done)
                }
                .padding(.horizontal)

                // Goal Input
                VStack(alignment: .leading, spacing: 10) {
                    Text("DAILY GOAL").font(.caption).opacity(0.6)
                    HStack {
                        Text("\(habit.frequencyCount) times")
                        Spacer()
                        Stepper("", value: $habit.frequencyCount, in: 1...100)
                            .labelsHidden()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.1)))
                }
                .padding(.horizontal)

                Spacer()
                
                Button(role: .destructive) {
                    deleteHabit()
                } label: {
                    Text("Delete Habit")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 1))
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .foregroundStyle(.white)
        }
    }
    
    private func deleteHabit() {
        modelContext.delete(habit)
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        try? modelContext.save()
        dismiss()
    }
}
