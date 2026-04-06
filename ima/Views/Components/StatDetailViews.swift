//
//  StatDetailViews.swift
//  ima/Views/Components
//
//  Shared stat info sheet and profile stat detail components.
//

import SwiftUI

// MARK: - Stat Info Sheet (compact — used by habit info sheet stats)

struct StatInfoSheet: View {
    let title: String
    let value: String
    let description: String
    var compact: Bool = false
    @Environment(\.appBackground) private var appBackground

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.white.opacity(0.5))
                .frame(width: 36, height: 5)
                .padding(.top, 12)

            VStack(spacing: compact ? 10 : 20) {
                Text(value)
                    .font(.system(size: compact ? 28 : 34, weight: .bold))
                    .foregroundStyle(.white)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.5))
                    .textCase(.uppercase)
                    .kerning(1.0)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, compact ? 0 : 8)
            }
            .padding(.top, compact ? 12 : 24)
            .padding(.bottom, compact ? 16 : 24)

            if compact { Spacer() }
        }
        .frame(maxWidth: .infinity)
        .presentationDetents([compact ? .height(200) : .medium])
        .presentationDragIndicator(.hidden)
        .presentationBackground(appBackground)
        .presentationCornerRadius(40)
    }
}

// MARK: - Profile Stat Detail Shell (rich — used by profile stats)

struct ProfileStatDetailShell<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    let description: String
    @ViewBuilder var visual: () -> Content
    @Environment(\.appBackground) private var appBackground

    @State private var iconVisible = false
    @State private var titleVisible = false
    @State private var dataVisible = false
    @State private var descVisible = false

    var body: some View {
        VStack(spacing: 0) {
            // Drag pill
            Capsule()
                .fill(Color.white.opacity(0.5))
                .frame(width: 36, height: 5)
                .padding(.top, 12)

            // Icon with color glow
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.2), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 16)

                Image(systemName: icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(color.gradient)
                    .shadow(color: color.opacity(0.3), radius: 8)
            }
            .padding(.top, 8)
            .scaleEffect(iconVisible ? 1.0 : 0.5)
            .opacity(iconVisible ? 1.0 : 0)

            // Title
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 32)
                .padding(.top, 4)
                .offset(y: titleVisible ? 0 : 12)
                .opacity(titleVisible ? 1.0 : 0)

            // Visual data
            visual()
                .padding(.top, 14)
                .padding(.horizontal, 8)
                .scaleEffect(dataVisible ? 1.0 : 0.95)
                .opacity(dataVisible ? 1.0 : 0)

            Spacer()

            // Description
            Text(description)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 28)
                .opacity(descVisible ? 1.0 : 0)
        }
        .frame(maxWidth: .infinity)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .presentationBackground(appBackground)
        .presentationCornerRadius(40)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                iconVisible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                titleVisible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2)) {
                dataVisible = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.35)) {
                descVisible = true
            }
        }
    }
}

// MARK: - Animated Progress Bar

struct AnimatedBar: View {
    let progress: Double
    let color: Color
    var height: CGFloat = 6
    var delay: Double = 0.3

    @State private var animatedProgress: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.1))
                Capsule().fill(color.gradient)
                    .frame(width: geo.size.width * animatedProgress)
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(delay)) {
                animatedProgress = progress
            }
        }
    }
}
