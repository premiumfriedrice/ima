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


/*
 // MARK: - Subviews
 struct SectionHeader: View {
     let icon: String
     let color: Color
     let title: String
     let subtitle: String = ""
     
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
 
 */


/*
 // MARK: - Header Component
 // Reused design language from HabitGroupView
 struct TaskSectionHeader: View {
     let title: String
     let count: Int
     let color: Color
     
     var body: some View {
         HStack(spacing: 5) {
             Image(systemName: "exclamationmark.circle.fill")
                 .font(.headline)
                 .foregroundStyle(color)
             
             Text(title)
                 .font(.caption)
                 .foregroundStyle(.primary)
                 .textCase(.uppercase)
             
             // Divider Dot
             Circle()
                 .fill(.white.opacity(0.3))
                 .frame(width: 4, height: 4)
             
             // Count Subtitle
             Text("\(count) Task")
                 .font(.caption)
                 .foregroundStyle(.secondary)
                 .textCase(.uppercase)
             
             Spacer()
         }
         // Glassmorphism background for sticky effect
         .background(.ultraThinMaterial.opacity(0.01))
         .font(.system(.caption, design: .rounded))
 //        .fontWeight(.bold)
         .textCase(.uppercase)
         .kerning(1.0)
         .opacity(0.7) // Increased opacity slightly for readability
         .foregroundStyle(.white)
         .padding(.leading, 25)
         .padding(.top, 10)
     }
 }
 
 */
