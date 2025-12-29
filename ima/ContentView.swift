//
//  ContentView.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/22/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \Habit.title) private var habits: [Habit]
    
    
    @State private var selectedTab: AppTab = .habits
    @State private var showingCreateSheet = false
    
    private let dayChanged = NotificationCenter.default.publisher(for: .NSCalendarDayChanged)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.black).ignoresSafeArea()
            AnimatedRadialBackground()
            VStack {
                Group {
                    switch selectedTab {
                    case .habits:
                        VStack{
                            HabitGroupView(habits: habits)
                                .accessibilityIdentifier("HabitList")
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        
                    case .usertasks:
                        Text("Tasks Coming Soon")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .textCase(.uppercase)
                            .kerning(1.0)
                            .opacity(0.5)
                            .foregroundStyle(.white)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedTab)
                
                NavFooterView(showingCreateSheet: $showingCreateSheet, selectedTab: $selectedTab)
                
            }
            
        }
        .sheet(isPresented: $showingCreateSheet) {
            if selectedTab == .habits {
                CreateHabitView()
            }
            else if selectedTab == .usertasks {
                Text("Create Sheet Here")
                    .presentationDetents([.fraction(0.7)])
            }
        }
        .onAppear {
            Habit.resetHabitsIfNeeded(habits: habits)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in // iOS 17+ Syntax
            if newPhase == .active {
                Habit.resetHabitsIfNeeded(habits: habits)
            }
        }
        .onReceive(dayChanged) { _ in
            Habit.resetHabitsIfNeeded(habits: habits)
        }
//        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Habit.self, inMemory: true)
}
