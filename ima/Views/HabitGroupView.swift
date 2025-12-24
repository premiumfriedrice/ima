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
    @State private var showingCreateSheet = false
    @State private var selectedTab = 0 // 0 for Habits, 1 for Tasks
    @State private var animateArrow = false
    
    var habits: [Habit]
    
    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Main Content Area
            Group {
                if selectedTab == 0 {
                    ScrollView {
                        VStack(spacing: 16) {
                            Color.clear.frame(height: 64)
                            ForEach(habits) { habit in
                                HabitCardView(habit: habit)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 150)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    VStack {
                        Spacer()
                        Text("Tasks Coming Soon")
                            .foregroundStyle(.white.opacity(0.5))
                            .font(.headline)
                        Spacer()
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedTab)
            
            // MARK: - Floating Header
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    // Swipable Title Area anchored to the leading edge
                    TabView(selection: $selectedTab) {
                        HStack(spacing: 12) {
                            Text("Habits")
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)
                            
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.3))
                                .offset(x: animateArrow ? 6 : 0)
                            
                            Spacer() // Pushes "Habits" to the leading edge
                        }
                        .tag(0)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.3))
                                .offset(x: animateArrow ? -6 : 0)
                            
                            Text("Tasks")
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)
                            
                            Spacer() // Pushes "Tasks" to the leading edge
                        }
                        .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 36)
                    .frame(maxWidth: .infinity, alignment: .leading) // Ensures TabView content stays leading
                    
                    Button(action: { showingCreateSheet = true }) {
                        Image(systemName: "plus")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 36)
                .padding(.top, 16)
                
                Color.clear.frame(height: 40)
            }
            .background(alignment: .top) {
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.1, green: 0.1, blue: 0.1), location: 0.6),
                        .init(color: Color(red: 0.1, green: 0.1, blue: 0.1).opacity(0), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            CreateSheetView()
        }
        .onAppear {
            startArrowTimer()
        }
    }
    
    private func startArrowTimer() {
        Timer.scheduledTimer(withTimeInterval: 12.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5).repeatCount(3, autoreverses: true)) {
                animateArrow = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                animateArrow = false
            }
        }
    }
}
