//
//  SettingsView.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 1/13/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("lockRotation") private var lockRotation: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Settings")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 30)
                
                VStack(spacing: 16) {
                    
                    // General
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "General", icon: "gear", color: .gray)
                        
                        VStack(spacing: 1) {
                            SettingsRow(icon: "iphone", title: "Lock Rotation", color: .blue) {
                                Toggle("", isOn: $lockRotation)
                                    .tint(.blue)
                            }
                            
                            Divider().background(.white.opacity(0.1)).padding(.leading, 50)
                            
                            SettingsRow(icon: "hand.tap.fill", title: "Haptic Feedback", color: .green) {
                                Toggle("", isOn: $hapticsEnabled)
                                    .tint(.green)
                            }
                        }
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    
                    // Data
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Data", icon: "externaldrive.fill", color: .orange)
                        
                        VStack(spacing: 1) {
                            SettingsRow(icon: "icloud.fill", title: "iCloud Sync", color: .cyan) {
                                Text("On")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.bottom, 20)
            }
        }
    }
}

// Reuse helper for consistency
struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    let content: () -> Content
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(color)
            }
            
            Text(title)
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
                .foregroundStyle(.white)
            
            Spacer()
            
            content()
        }
        .padding(16)
    }
}
