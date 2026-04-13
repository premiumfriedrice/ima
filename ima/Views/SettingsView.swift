//
//  SettingsView.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 1/13/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appBackground) private var appBackground
    @AppStorage("appBackground") private var backgroundRaw: String = AppBackground.charcoal.rawValue

    var body: some View {
        NavigationStack {
            ZStack {
                appBackground.ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: - Swipe Pill
                    Capsule()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 36, height: 5)
                        .padding(.top, 12)

                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PREFERENCES")
                            .font(.caption2)
                            .textCase(.uppercase)
                            .kerning(1.0)
                            .opacity(0.5)
                            .foregroundStyle(.white)

                        Text("Settings")
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 25)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    ScrollView {
                        VStack(spacing: 28) {

                            // MARK: - Appearance
                            VStack(alignment: .leading, spacing: 10) {
                                Text("APPEARANCE")
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)

                                colorRow(options: Array(AppBackground.allCases))
                            }

                            // MARK: - Support & Legal
                            VStack(alignment: .leading, spacing: 10) {
                                Text("SUPPORT & LEGAL")
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)

                                VStack(spacing: 0) {
                                    Link(destination: URL(string: "mailto:sudofriedrice@gmail.com")!) {
                                        SettingsRow(icon: "envelope.fill", title: "Contact Us", color: .pink) {
                                            Image(systemName: "arrow.up.right")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(.white.opacity(0.3))
                                        }
                                    }

                                    Rectangle()
                                        .fill(.white.opacity(0.1))
                                        .frame(height: 0.5)
                                        .padding(.leading, 56)

                                    NavigationLink {
                                        LegalPageView(title: "Privacy Policy", content: """
Last updated: April 2026

ima is designed with your privacy in mind. Here's what you need to know:

DATA COLLECTION
ima does not collect, transmit, or share any personal data. All information you enter — including habits, tasks, subtasks, profile name, tagline, and preferences — is stored entirely on your device.

DATA STORAGE
All data is stored locally using Apple's SwiftData framework and UserDefaults. Your data never leaves your device. There are no servers, no cloud sync, and no accounts.

THIRD-PARTY SERVICES
ima does not use any third-party analytics, advertising, or tracking services. There are no SDKs that collect data about your usage.

CONTACT INFORMATION
The optional profile name and tagline you enter are stored locally on your device and are never transmitted anywhere.

DATA DELETION
You can delete all app data at any time by deleting the app from your device. Individual habits and tasks can be deleted from within the app.

CHANGES TO THIS POLICY
If this policy changes in a future update, you will be notified through the App Store update notes.

CONTACT
If you have questions about this privacy policy, contact us at sudofriedrice@gmail.com.
""")
                                    } label: {
                                        SettingsRow(icon: "hand.raised.fill", title: "Privacy Policy", color: .blue) {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(.white.opacity(0.3))
                                        }
                                    }

                                    Rectangle()
                                        .fill(.white.opacity(0.1))
                                        .frame(height: 0.5)
                                        .padding(.leading, 56)

                                    NavigationLink {
                                        LegalPageView(title: "Terms & Conditions", content: """
Last updated: April 2026

By using ima, you agree to the following terms:

USE OF THE APP
ima is a personal productivity app for tracking habits and tasks. You may use it for personal, non-commercial purposes.

YOUR DATA
All data you create in ima is yours. It is stored locally on your device. We do not have access to your data and cannot recover it if lost.

DISCLAIMER
ima is provided "as is" without warranties of any kind. We are not responsible for any loss of data, missed habits, or incomplete tasks.

LIMITATION OF LIABILITY
To the maximum extent permitted by law, the developers of ima shall not be liable for any damages arising from the use or inability to use the app.

APP STORE
Your use of ima is also subject to Apple's Terms of Service and App Store guidelines.

CHANGES
We may update these terms from time to time. Continued use of the app after changes constitutes acceptance of the updated terms.

CONTACT
Questions about these terms can be directed to sudofriedrice@gmail.com.
""")
                                    } label: {
                                        SettingsRow(icon: "doc.text.fill", title: "Terms & Conditions", color: .yellow) {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(.white.opacity(0.3))
                                        }
                                    }
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(.ultraThinMaterial.opacity(0.1))
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(.white.opacity(0.15), lineWidth: 1)
                                }
                            }

                            // Version
                            Text("Version 1.0.0")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.25))
                                .frame(maxWidth: .infinity)
                                .padding(.top, 8)
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .background(appBackground)
            .navigationBarHidden(true)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(appBackground)
        .presentationCornerRadius(40)
        .overlay {
            RoundedRectangle(cornerRadius: 40)
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.2), location: 0.0),
                            .init(color: .white.opacity(0.05), location: 0.2),
                            .init(color: .clear, location: 0.5)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 3
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
    }

    // MARK: - Color Row Helper
    @ViewBuilder
    private func colorRow(options: [AppBackground]) -> some View {
        HStack(spacing: 0) {
            ForEach(options) { bg in
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        backgroundRaw = bg.rawValue
                    }
                    // Switch app icon to match
                    UIApplication.shared.setAlternateIconName(bg.iconName)
                } label: {
                    VStack(spacing: 6) {
                        Circle()
                            .fill(bg.color)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(
                                        backgroundRaw == bg.rawValue
                                            ? Color.white.opacity(0.8)
                                            : Color.white.opacity(0.15),
                                        lineWidth: backgroundRaw == bg.rawValue ? 2 : 1
                                    )
                            )
                            .shadow(
                                color: backgroundRaw == bg.rawValue
                                    ? Color.white.opacity(0.15) : .clear,
                                radius: 6
                            )

                        Text(bg.rawValue)
                            .font(.system(size: 8))
                            .foregroundStyle(
                                backgroundRaw == bg.rawValue
                                    ? Color.white.opacity(0.8)
                                    : Color.white.opacity(0.4)
                            )
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Settings Row

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    let content: () -> Content

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(color)
            }

            Text(title)
                .font(.body)
                .foregroundStyle(.white)

            Spacer()

            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

// MARK: - Privacy Policy

struct LegalPageView: View {
    let title: String
    let content: String
    @Environment(\.appBackground) private var appBackground
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Drag pill
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)

                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.callout)
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(10)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                VStack(alignment: .leading, spacing: 10) {
                    Text("LEGAL")
                        .font(.caption2)
                        .textCase(.uppercase)
                        .kerning(1.0)
                        .opacity(0.5)
                        .foregroundStyle(.white)

                    Text(title)
                        .font(.title)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 25)
                .padding(.top, 8)
                .padding(.bottom, 16)

                ScrollView {
                    Text(content)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)
                }
                .scrollIndicators(.hidden)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
