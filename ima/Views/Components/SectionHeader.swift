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
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(color)
            
            Text(title)
                .font(.headline)
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
            Spacer()
        }
        .font(.system(.caption, design: .rounded))
        .textCase(.uppercase)
        .kerning(1.0)
        .opacity(0.7)
        .foregroundStyle(.white)
        .padding(.leading, 25)
        .padding(.vertical, 10)
    }
}
