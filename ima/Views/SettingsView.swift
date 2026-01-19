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
                // Header
                Text("Settings")
                    .font(.title2) // Standard system font
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.top, 30)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Support & Legal Section (NEW)
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "Support & Legal", icon: "doc.text.fill", color: .purple)
                            
                            VStack(spacing: 1) {
                                // 1. Contact Us
                                Link(destination: URL(string: "mailto:support@ima.app")!) {
                                    SettingsRow(icon: "envelope.fill", title: "Contact Us", color: .pink) {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.white.opacity(0.3))
                                    }
                                }
                                
                                Divider().background(.white.opacity(0.1)).padding(.leading, 50)
                                
                                // 2. Privacy Policy
                                Link(destination: URL(string: "https://www.google.com")!) {
                                    SettingsRow(icon: "hand.raised.fill", title: "Privacy Policy", color: .blue) {
                                        Image(systemName: "arrow.up.right")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.white.opacity(0.3))
                                    }
                                }
                                
                                Divider().background(.white.opacity(0.1)).padding(.leading, 50)
                                
                                // 3. Terms & Conditions
                                // Replace string with your actual URL
                                Link(destination: URL(string: "https://www.google.com")!) {
                                    SettingsRow(icon: "doc.text.fill", title: "Terms & Conditions", color: .yellow) {
                                        Image(systemName: "arrow.up.right")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.white.opacity(0.3))
                                    }
                                }
                            }
                            .background(Color.white.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Helper Views

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    let content: () -> Content
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(color)
            }
            
            Text(title)
                .font(.body) // System font
                .fontWeight(.medium)
                .foregroundStyle(.white)
            
            Spacer()
            
            content()
        }
        .padding(16)
        .contentShape(Rectangle()) // Ensures the whole row is tappable inside the Link
    }
}
