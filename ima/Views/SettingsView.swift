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
    @AppStorage("appBackground") private var backgroundRaw: String = AppBackground.pureBlack.rawValue

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
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)
                        .padding(.top, 24)

                    ScrollView {
                        VStack(spacing: 24) {

                            // MARK: - Appearance
                            VStack(alignment: .leading, spacing: 10) {
                                Text("APPEARANCE")
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)
                                    .padding(.leading, 5)

                                HStack(spacing: 0) {
                                    ForEach(AppBackground.allCases) { bg in
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                backgroundRaw = bg.rawValue
                                            }
                                        } label: {
                                            VStack(spacing: 6) {
                                                Circle()
                                                    .fill(bg.color)
                                                    .frame(width: 40, height: 40)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(
                                                                backgroundRaw == bg.rawValue
                                                                    ? .white.opacity(0.8)
                                                                    : .white.opacity(0.15),
                                                                lineWidth: backgroundRaw == bg.rawValue ? 2 : 1
                                                            )
                                                    )
                                                    .shadow(
                                                        color: backgroundRaw == bg.rawValue
                                                            ? .white.opacity(0.15)
                                                            : .clear,
                                                        radius: 6
                                                    )

                                                Text(bg.rawValue)
                                                    .font(.system(size: 9))
                                                    .foregroundStyle(
                                                        backgroundRaw == bg.rawValue
                                                            ? .white.opacity(0.8)
                                                            : .white.opacity(0.4)
                                                    )
                                                    .lineLimit(1)
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(16)
                                .background {
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(.ultraThinMaterial.opacity(0.1))
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(.white.opacity(0.15), lineWidth: 1)
                                }
                            }

                            // MARK: - Support & Legal
                            VStack(alignment: .leading, spacing: 10) {
                                Text("SUPPORT & LEGAL")
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)
                                    .padding(.leading, 5)

                                VStack(spacing: 0) {
                                    // Contact Us
                                    Link(destination: URL(string: "mailto:support@ima.app")!) {
                                        SettingsRow(
                                            icon: "envelope.fill",
                                            title: "Contact Us",
                                            color: .pink
                                        ) {
                                            Image(systemName: "arrow.up.right")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(.white.opacity(0.3))
                                        }
                                    }

                                    Divider()
                                        .background(.white.opacity(0.08))
                                        .padding(.leading, 56)

                                    // Privacy Policy (in-app)
                                    NavigationLink {
                                        PrivacyPolicyView()
                                    } label: {
                                        SettingsRow(
                                            icon: "hand.raised.fill",
                                            title: "Privacy Policy",
                                            color: .blue
                                        ) {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(.white.opacity(0.3))
                                        }
                                    }

                                    Divider()
                                        .background(.white.opacity(0.08))
                                        .padding(.leading, 56)

                                    // Terms & Conditions
                                    NavigationLink {
                                        TermsView()
                                    } label: {
                                        SettingsRow(
                                            icon: "doc.text.fill",
                                            title: "Terms & Conditions",
                                            color: .yellow
                                        ) {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(.white.opacity(0.3))
                                        }
                                    }
                                }
                                .background(Color.white.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 24)
                    }
                    .scrollIndicators(.hidden)

                    Spacer()

                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.3))
                        .padding(.bottom, 20)
                }
            }
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

struct PrivacyPolicyView: View {
    @Environment(\.appBackground) private var appBackground

    var body: some View {
        ZStack {
            appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text("This privacy policy will be updated soon.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(appBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Terms & Conditions

struct TermsView: View {
    @Environment(\.appBackground) private var appBackground

    var body: some View {
        ZStack {
            appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Terms & Conditions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text("Terms and conditions will be updated soon.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(appBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
