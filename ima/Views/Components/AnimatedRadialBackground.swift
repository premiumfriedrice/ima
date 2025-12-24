//
//  AnimatedRadialBackground.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/23/25.
//

import SwiftUI

struct AnimatedRadialBackground: View {
    @State private var animate = false
    
    var body: some View {
        AnimatedRadial(color: Color.blue.opacity(0.05),
                       startPoint: .bottomTrailing,
                       endPoint: .bottomLeading)
        AnimatedRadial(color: Color.white.opacity(0.05),
                       startPoint: .topLeading,
                       endPoint: .topTrailing)
    }
}
