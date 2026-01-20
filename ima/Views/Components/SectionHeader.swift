//
//  SectionHeader.swift
//  ima/Views/Components
//
//  Created by Lloyd Derryk Mudanza Alba on 12/23/25.
//

import SwiftUI
import SwiftData

struct SectionHeader: View {
    let title: String
    var subtitle: String = ""
    let icon: String
    let color: Color
    
    // 1. Optional coordinate space to enable sticky background logic
    var coordinateSpace: String? = nil
    
    var body: some View {
        HStack(spacing: 5) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .textCase(.uppercase)
                
               if !subtitle.isEmpty {
                // Divider Dot
                Circle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 4, height: 4)
                
                // Date/Subtitle
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
               }

           }
            .padding(.vertical, 5)
            .padding(.horizontal, 5)
//            .background {
//                Capsule() // The "Pill" Spotlight
//                    .fill(.ultraThickMaterial.opacity(0.5))
//                    .blur(radius: 10)
//            }
            Spacer()
        }
        .font(.system(.caption, design: .rounded))
        .textCase(.uppercase)
        .kerning(1.0)
        .foregroundStyle(.white)
        .padding(.leading, 15)
        .padding(.vertical, 10)
        // 2. Apply the sticky background helper if a coordinate space is provided
        .background {
            if let coordinateSpace {
                StickyHeaderBackground(coordinateSpace: coordinateSpace)
            }
        }
    }
}

// MARK: - Helper View for Sticky Logic
struct StickyHeaderBackground: View {
    let coordinateSpace: String
    
    var body: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .named(coordinateSpace)).minY
            let fadeDistance: CGFloat = 20.0
            
            // Calculate opacity (0 to 1) based on scroll position
            // 0 when far down, 1 when pinned at top
            let opacity = max(0, min(1, 1 - (minY / fadeDistance)))
            
            LinearGradient(
                stops: [
                    .init(color: .black, location: 0.85), // Solid black base
                    .init(color: .clear, location: 1.0)   // Fades edge
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(opacity)
        }
    }
}
