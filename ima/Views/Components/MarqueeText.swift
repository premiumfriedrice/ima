//
//  MarqueeText.swift
//  ima/Views/Components
//
//  Auto-scrolling text for long titles that don't fit in one line.
//

import SwiftUI

struct MarqueeText: View {
    let text: String
    var font: Font = .body
    var foregroundStyle: Color = .white

    @State private var animate = false
    @State private var textNeedsScroll = false
    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0

    private let gap: CGFloat = 40
    private let speed: CGFloat = 30

    private var duration: Double {
        Double(textWidth + gap) / Double(speed)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Hidden measurer
                Text(text)
                    .font(font)
                    .fixedSize()
                    .hidden()
                    .background {
                        GeometryReader { textGeo in
                            Color.clear
                                .preference(key: TextWidthKey.self, value: textGeo.size.width)
                        }
                    }

                if textNeedsScroll {
                    HStack(spacing: gap) {
                        Text(text)
                            .font(font)
                            .foregroundStyle(foregroundStyle)
                            .fixedSize()

                        Text(text)
                            .font(font)
                            .foregroundStyle(foregroundStyle)
                            .fixedSize()
                    }
                    .offset(x: animate ? -(textWidth + gap) : 0)
                    .animation(
                        animate ? .linear(duration: duration).repeatForever(autoreverses: false) : .none,
                        value: animate
                    )
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            animate = true
                        }
                    }
                } else {
                    Text(text)
                        .font(font)
                        .foregroundStyle(foregroundStyle)
                        .lineLimit(1)
                }
            }
            .frame(width: geo.size.width, alignment: .leading)
            .clipped()
            .onPreferenceChange(TextWidthKey.self) { width in
                textWidth = width
                containerWidth = geo.size.width
                textNeedsScroll = width > geo.size.width
            }
        }
        .frame(height: 20)
    }
}

private struct TextWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
