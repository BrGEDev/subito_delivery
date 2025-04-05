//
//  Picker.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 03/04/25.
//

import SwiftUI

struct PropinaPicker: View {
    
    var porcentajes: [Int] = [5, 10, 15, 20]
    @Binding var segment: Int
    
    var body: some View {
        HStack() {
            ForEach(porcentajes, id:\.self) { i in
                
                HStack(alignment: .center) {
                    Text("\(i)%")
                }
                .padding(5)
                .frame(maxWidth: .infinity)
                .background(i == segment ? Color.accentColor : Color.clear)
                .foregroundStyle(segment == i ? Color.black : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onTapGesture {
                    withAnimation(.linear(duration: 0.1)) {
                        segment = i
                    }
                }
                
                Spacer()
            }
            
            HStack(alignment: .center) {
                Text("Otro")
            }
            .padding(5)
            .frame(maxWidth: .infinity)
            .background(segment == -1 ? Color.accentColor : Color.clear)
            .foregroundStyle(segment == -1 ? Color.black : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture {
                withAnimation(.linear(duration: 0.1)) {
                    segment = -1
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Material.ultraThin)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct ModalPropina: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel = PrePurchaseViewModel.shared
    @Binding var alert: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextField("Propina", value: $viewModel.propina, format: .number)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(
                        colorScheme == .dark
                        ? Color.white.opacity(0.1).cornerRadius(20)
                        : Color.black.opacity(0.06).cornerRadius(20)
                    )
                    .keyboardType(.numberPad)
                    .onChange(of: viewModel.propina) { oldval, value in
                        viewModel.propina = value > 40 ? 40 : value
                    }
                
                Button(action: {
                    if viewModel.propina <= 0 {
                        alert = true
                    } else {
                        viewModel.modalPropina = false
                        viewModel.calcTax()
                    }
                }) {
                    Text("Continuar")
                }
                .foregroundColor(.black)
                .frame(width: 200, height: 50)
                .background(Color.accentColor)
                .cornerRadius(20)
                .padding()
                .alert(isPresented: $alert) {
                    Alert(
                        title: Text("Error"),
                        message: Text("La propina debe ser mayor al 0%"),
                        dismissButton: .default(Text("Aceptar")))
                }
                
                Button(action: {
                    viewModel.modalPropina = false
                    viewModel.propina = 0
                    viewModel.segment = 0
                    viewModel.calcTax()
                }) {
                    Text("Sin propina")
                }
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(width: 200, height: 50)
                .background(Material.bar)
                .cornerRadius(20)
            }
            .navigationTitle("Propina")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
