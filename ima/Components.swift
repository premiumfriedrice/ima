//
//  HabitCardView.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/22/25.
//

import SwiftUI
import SwiftData

struct SegmentedProgressBar: View {
    let value: Int
    let total: Int
    let color: Color
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1))
                
                Capsule()
                    .fill(color)
                    .frame(width: geo.size.width * CGFloat(Double(value) / Double(max(total, 1))))
                
                HStack(spacing: 0) {
                    ForEach(1..<total, id: \.self) { _ in
                        Spacer()
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 2)
                    }
                    Spacer()
                }
            }
        }
        .clipShape(Capsule())
    }
}

struct HabitCardView: View {
    @Bindable var habit: Habit // Use Bindable for SwiftData objects
    
    var isDoneForToday: Bool {
        habit.countDoneToday >= habit.dailyGoal
    }
    
    var statusColor: Color {
        if isDoneForToday {
            return .green
        } else if habit.countDoneToday > 0 || habit.totalCount > 0 {
            return .orange
        } else {
            return .white.opacity(0.4)
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(habit.title)
                    .font(.headline)
                
                Text("\(habit.totalCount)/\(habit.frequencyCount) \(habit.frequencyUnit == .daily ? "today" : "this week")")
                    .font(.caption)
                    .opacity(0.7)
                
                SegmentedProgressBar(
                    value: habit.totalCount,
                    total: habit.frequencyCount,
                    color: statusColor
                )
                .frame(height: 5)
            }
            .foregroundStyle(.white)
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    if !isDoneForToday {
                        habit.countDoneToday += 1
                        habit.totalCount += 1
                    } else {
                        habit.totalCount -= habit.countDoneToday
                        habit.countDoneToday = 0
                    }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }) {
                Image(systemName: isDoneForToday ? "square.fill" : "square")
                    .font(.system(size: 28))
                    .foregroundColor(statusColor)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(statusColor.opacity(0.2)))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(statusColor, lineWidth: 1))
        .opacity(isDoneForToday ? 0.4 : 1.0)
        .padding(.horizontal)
    }
}

struct PillMenuBar: View {
    @Binding var selectedIndex: Int
    let tabs: [String]
    let baseColor: Color
    @Namespace private var animationNamespace
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedIndex = index
                    }
                }) {
                    Text(tabs[index])
                        .fontWeight(.heavy)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(selectedIndex == index ? .white : .primary.opacity(0.6))
                        .background(
                            ZStack {
                                if selectedIndex == index {
                                    Capsule()
                                        .fill(Color.blue)
                                        .matchedGeometryEffect(id: "tab", in: animationNamespace)
                                }
                            }
                        )
                }
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(baseColor.opacity(0.5))
                .background(Capsule().stroke(baseColor.opacity(0.2), lineWidth: 1))
        )
        .padding(.horizontal, 30)
    }
}
