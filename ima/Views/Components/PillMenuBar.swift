//
//  PillMenuBar.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/23/25.
//

import SwiftUI
import SwiftData

struct PillMenuBar: View {
    @Binding var selectedIndex: Int
    let tabs: [String]
    let baseColor: Color
    @Namespace private var animationNamespace
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedIndex = index
                    }
                }) {
                    Text(tabs[index])
                        .fontWeight(.heavy)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(selectedIndex == index ? .white : .primary.opacity(0.6))
                        .background(
                            ZStack {
                                if selectedIndex == index {
                                    Capsule()
                                        .fill(Color.blue)
                                        .matchedGeometryEffect(id: "tab", in: animationNamespace)
                                }
                            }
                        )
                }
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(baseColor.opacity(0.5))
                .background(Capsule().stroke(baseColor.opacity(0.2), lineWidth: 1))
        )
        .padding(.horizontal, 30)
    }
}
