//
//  NavFooterView.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/24/25.
//

import SwiftUI

// Define the source of truth for your tabs
enum AppTab: Int, CaseIterable, Identifiable {
    case habits = 0
    case tasks = 1
    
    var id: Int { self.rawValue }
    
    var title: String {
        switch self {
        case .habits: return "Habits"
        case .tasks: return "Tasks"
        }
    }
}

struct NavFooterView: View {
    @Binding var showingCreateSheet: Bool
    @Binding var selectedTab: AppTab
    @State private var animateArrow = false
    
    var body: some View {
        // MARK: - Floating Header
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                // Swipable Title Area anchored to the leading edge
                TabView(selection: $selectedTab) {
                    ForEach(AppTab.allCases) { tab in
                        HStack(spacing: 12) {
                            // Back indicator only on Tasks
//                            if tab == .tasks {
//                                Image(systemName: "chevron.left")
//                                    .font(.title3)
//                                    .foregroundStyle(.white.opacity(0.3))
//                                    .offset(x: animateArrow ? -6 : 0)
//                            }
                            
                            Text(tab.title)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            // Forward indicator only on Habits
//                            if tab == .habits {
//                                Image(systemName: "chevron.right")
//                                    .font(.title3)
//                                    .foregroundStyle(.white.opacity(0.3))
//                                    .offset(x: animateArrow ? 6 : 0)
//                            }
                            
                            Spacer()
                        }
                        .tag(tab)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 36)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: { showingCreateSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.trailing, 15)
            }
            .padding(.horizontal, 36)
            .padding(.top, 64)
            
            Color.clear.frame(height: 8)
        }
        .background(alignment: .top) {
            LinearGradient(
                stops: [
                    .init(color: Color(.black), location: 0.6),
                    .init(color: Color(.black).opacity(0), location: 1.0)
                ],
                startPoint: .bottom, // Kept your specific gradient direction
                endPoint: .top
            )
            .ignoresSafeArea()
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
