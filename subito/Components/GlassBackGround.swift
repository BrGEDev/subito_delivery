//
//  GlassBackGround.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 21/03/25.
//

import SwiftUI

struct GlassBackGround: View {
    var width: CGFloat
    var height: CGFloat? = nil
    var color: Color
    var radius: CGFloat = 25
    var border: Bool = true

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [.clear, color],
                center: .center,
                startRadius: 1,
                endRadius: 100
            )
            .opacity(0.6)
            Rectangle().foregroundColor(color)
        }
        .opacity(0.2)
        .blur(radius: 2)
        .cornerRadius(radius)
        .overlay(
            RoundedRectangle(cornerRadius: radius)
                .stroke(color, lineWidth: border ? 1 : 0)
        )
        .frame(maxWidth: width, maxHeight: height ?? .infinity)
    }
}
