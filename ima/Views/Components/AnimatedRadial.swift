//
//  AnimtedRadial.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/23/25.
//

import SwiftUI

struct AnimatedRadial: View {
    @State private var animate = false
    var color: Color
    var startPoint: UnitPoint
    var endPoint: UnitPoint
    
    var body: some View {
        ZStack {
            // Animated Glow
            RadialGradient(
                gradient: Gradient(colors: [color, .clear]),
                center: animate ? startPoint : endPoint, // Move the center
                startRadius: 100,
                endRadius: 500
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 30).repeatForever(autoreverses: true)) {
                    animate.toggle()
                }
            }
        }
    }
}
