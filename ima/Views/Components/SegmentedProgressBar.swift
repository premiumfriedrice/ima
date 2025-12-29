//
//  SegmentedProgressBar.swift
//  ima/Views/Components
//
//  Created by Lloyd Derryk Mudanza Alba on 12/23/25.
//

import SwiftUI
import SwiftData

struct SegmentedProgressBar: View {
    let value: Int
    let total: Int
    let color: Color
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1))
                
                Capsule()
                    .fill(color)
                    .frame(width: geo.size.width * CGFloat(Double(value) / Double(max(total, 1))))
                
                HStack(spacing: 0) {
                    ForEach(1..<total, id: \.self) { _ in
                        Spacer()
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 2)
                    }
                    Spacer()
                }
            }
        }
        .clipShape(Capsule())
        .accessibilityIdentifier("ProgressBar")
    }
}
