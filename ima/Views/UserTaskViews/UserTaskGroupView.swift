//
//  UserTaskGroupView.swift
//  ima/Views/UserTaskViews
//
//  Created by Lloyd Derryk Mudanza Alba on 12/29/25.
//

import SwiftUI
import SwiftData

struct UserTaskGroupView: View {
    @Environment(\.modelContext) private var modelContext
    
//    var usertasks: [UserTask]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                // if usertask.empty()
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 60)) // Set icon size explicitly
                        .foregroundStyle(.white.opacity(0.5)) // Match your opacity
                    
                    VStack {
                        Text("No Tasks Yet")
                            .font(.system(.title2, design: .rounded)) // Explicitly Rounded
                            .fontWeight(.bold)
                        
                        Text("Tap the + button to create your first task.")
                            .font(.system(.body, design: .rounded))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                .padding(.top, 40)
                .font(.system(.caption, design: .rounded))
                .kerning(1.0)
                .opacity(0.5)
                .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    ZStack {
        Color(.black).ignoresSafeArea()
        AnimatedRadialBackground()
        UserTaskGroupView()
    }
}
