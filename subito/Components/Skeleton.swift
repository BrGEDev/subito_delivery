//
//  Skeleton.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 28/11/24.
//

import SwiftUI

struct SkeletonCellView: View {
    let primaryColor = Color(.init(gray: 0.9, alpha: 1.0))
    let secondaryColor  = Color(.init(gray: 0.8, alpha: 1.0))
    var width: CGFloat = 60
    var height: CGFloat = 60
    
    var body: some View {
        HStack {
            secondaryColor
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .clipped()
        }
    }
}


struct BlinkViewModifier: ViewModifier {
    let duration: Double
    @State private var blinking: Bool = false

    func body(content: Content) -> some View {
        content
            .opacity(blinking ? 0.3 : 1)
            .animation(.easeInOut(duration: duration).repeatForever(), value: blinking)
            .onAppear {
                blinking.toggle()
            }
    }
}

extension View {
    func blinking(duration: Double = 1) -> some View {
        modifier(BlinkViewModifier(duration: duration))
    }
}
