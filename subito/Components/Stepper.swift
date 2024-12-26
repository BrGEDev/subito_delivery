//
//  Stepper.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 20/11/24.
//

import SwiftUI

struct Stepper: View {
    @Binding var value: Int
    var `in`: ClosedRange<Int>
    
    @Environment(\.controlSize)
    var controlSize
    
    var max: String
    
    var padding: Double {
        switch controlSize {
        case .mini: return 4
        case .small: return 6
        default: return 8
        }
    }
        
    var body: some View {
        HStack {
            HStack {
                Button(action: {
                    if value <= 1{
                        value = 1
                    } else {
                        value -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .frame(width: 20, height: 50)
                }
                .buttonStyle(.borderless)
                .frame(width: 20, height: 50)
                    
                
                Text(value.formatted())
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 18))
                
                Button(action: {
                    if value < Int(max)! {
                        value += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .frame(width: 20, height: 50)
                }
                .buttonStyle(.borderless)
                .frame(width: 20, height: 50)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding(.horizontal, padding * 2)
            .background(Material.ultraThin)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 10)
        }
    }
}
