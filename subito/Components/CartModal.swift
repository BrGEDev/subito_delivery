//
//  CartModal.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 01/10/24.
//

import SwiftData
import SwiftUI
import AppIntents

struct productoView: View {
    @StateObject var api: ApiCaller = ApiCaller()

    @Environment(\.modelContext) var context
    @State var product: ProductsSD
    var establishment: Int
    @Binding var onDelete: Bool
    @State var updateModal: Bool = false
    
    @State var loading: Bool = false
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        VStack {
            VStack {
                HStack {
                    VStack {
                        AsyncImageCache(url: URL(string: product.image)) {
                            image in
                            image
                                .resizable()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .clipped()

                    VStack {
                        Text(product.product)
                            .bold()
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)

                        Text("x\(product.amount)")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.trailing, 10)

                    Spacer()

                    Text(
                        product.unit_price * Float(product.amount),
                        format: .currency(code: "MXN")
                    )
                    .bold()

                    Button(action: {
                        delete(product: product)
                    }) {
                        Image(systemName: "minus.circle.fill")
                    }
                    .tint(Color.red)
                }
                .padding()
            }
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture {
                updateModal = true
            }
        }
        .sheet(isPresented: $updateModal) {
            UpdateProduct(product: product, isPresented: $updateModal)
                .presentationDetents([.height(200)])
                .presentationCornerRadius(35)
                .presentationBackgroundInteraction(.disabled)
                .interactiveDismissDisabled(true)
        }
        .sheet(isPresented: $loading) {
            VStack {
                Image(.logo)
                    .resizable()
                    .frame(width: 90, height: 90)
                    .scaledToFit()
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(1)
                    .onAppear {
                        withAnimation(
                            Animation
                                .easeInOut(duration: 2)
                                .repeatForever(autoreverses: false)
                        ) {
                            rotation += 360
                        }
                    }
                
                Text("Eliminando producto...")
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .padding()
            }
            .presentationDetents([.height(280)])
            .presentationBackgroundInteraction(.disabled)
            .interactiveDismissDisabled(true)
            .presentationCornerRadius(35)
        }
    }
}

struct CartModal: View {
    @Environment(\.modelContext) var context
    @Binding var isPresented: Bool

    @StateObject var api: ApiCaller = ApiCaller()

    @Query var establishments: [CartSD]
    @Query var userData: [UserSD]
    var user: UserSD? { userData.first }
    
    @State var onDelete: Bool = false

    @State var paymentModal: Bool = false
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State var loading: Bool = false
    
    @ObservedObject var viewModel = PrePurchaseViewModel.shared

    var body: some View {
        NavigationView {
            Group {
                if establishments.count != 0 {
                    ScrollView {
                        
                        SiriTipView(intent: InCartSubito())
                            .padding([.leading, .trailing])
                        
                        ForEach(establishments) { est in
                            VStack {
                                HStack {
                                    Text(est.establishment)
                                        .font(.title3)
                                        .lineLimit(1)
                                        .truncationMode(.tail)

                                    Spacer()

                                    Button(action: {
                                        deleteAll()
                                    }) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 15))
                                    }
                                    .foregroundStyle(Color.red)
                                }
                                .padding()

                                ForEach(est.products) { prod in
                                    productoView(
                                        product: prod, establishment: est.id,
                                        onDelete: $onDelete)

                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Material.ultraThin)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(
                                color: Color.black.opacity(0.15), radius: 10
                            )
                            .padding()
                        }
                    }
                } else {
                    VStack {
                        Image(.logo)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                        
                        Text("Aún no hay productos en tu carrito")
                            .frame(maxWidth: 300, alignment: .center)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxHeight: 300)
                }
            }
            .onAppear {
                if user != nil {
                    viewModel.prePurchase(establishments: establishments, user: user!)
                }
            }
            .navigationTitle("Mi carrito")
            .safeAreaInset(edge: .bottom) {
                if establishments.count != 0 {
                    Button(action: {
                        paymentModal = true
                    }) {
                        Text(
                            "Pagar \(Text(loadPayment(), format: .currency(code: "MXN")))"
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(.system(size: 18))
                        .bold()
                    }
                    .foregroundColor(.black)
                    .frame(height: 50)
                    .background(.accent)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.2), radius: 10)
                    .padding()
                }
            }
            .toolbar {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark").padding(.trailing, 8)
                }
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.black)
                .cornerRadius(1000)
                .shadow(color: Color.black.opacity(0.4), radius: 5)
            }
            .sheet(isPresented: $paymentModal) {
                PaymentModal(isPresented: $isPresented)
            }
            .sheet(isPresented: $loading) {
                VStack {
                    Image(.logo)
                        .resizable()
                        .frame(width: 90, height: 90)
                        .scaledToFit()
                        .rotationEffect(.degrees(rotation))
                        .scaleEffect(1)
                        .onAppear {
                            withAnimation(
                                Animation
                                    .easeInOut(duration: 2)
                                    .repeatForever(autoreverses: false)
                            ) {
                                rotation += 360
                            }
                        }
                    
                    Text("Limpiando tu carrito...")
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .padding()
                }
                .presentationDetents([.height(280)])
                .presentationBackgroundInteraction(.disabled)
                .interactiveDismissDisabled(true)
                .presentationCornerRadius(35)
            }
        }
    }
}

struct UpdateProduct: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    @Query var userData: [UserSD]
    var user: UserSD? { userData.first }
    
    @StateObject var api = ApiCaller()
    var product: ProductsSD
    @State var amount: Int = 0
    
    @State var loading: Bool = false
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            if loading {
                VStack {
                    VStack {
                        Image(.logo)
                            .resizable()
                            .frame(width: 90, height: 90)
                            .scaledToFit()
                            .rotationEffect(.degrees(rotation))
                            .scaleEffect(1)
                            .onAppear {
                                withAnimation(
                                    Animation
                                        .easeInOut(duration: 2)
                                        .repeatForever(autoreverses: false)
                                ) {
                                    rotation += 360
                                }
                            }
                        
                        Text("Actualizando...")
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            } else {
                ZStack {
                    VStack{
                        HStack{
                            Spacer()
                            
                            Button(action: {
                                dismiss()
                            }){
                                Image(systemName: "xmark")
                                    .foregroundStyle(Color.black)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.white)
                            .buttonBorderShape(.circle)
                            .shadow(radius: 17)
                        }
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 20){
                        HStack {
                            VStack {
                                AsyncImageCache(url: URL(string: product.image)) { image in
                                    image
                                        .resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .clipped()
                            
                            VStack(spacing: 10) {
                                Text(product.product)
                                    .font(.title.bold())
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                
                                HStack {
                                    Button(action: {
                                        if amount > 0 {
                                            amount -= 1
                                        }
                                    }) {
                                        Image(systemName: "minus")
                                            .foregroundStyle(.black)
                                    }
                                    .padding()
                                    .frame(width: 25, height: 25)
                                    .background(Color.accentColor)
                                    .clipShape(.circle)
                                    .clipped()
                                    
                                    Text("Cantidad: \(amount)")
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(amount == 0 ? .red : .primary)
                                    
                                    Button(action: {
                                        amount += 1
                                    }) {
                                        Image(systemName: "plus")
                                            .foregroundStyle(.black)
                                    }
                                    .padding()
                                    .frame(width: 25, height: 25)
                                    .background(Color.accentColor)
                                    .clipShape(.circle)
                                    .clipped()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.trailing, 10)
                        }
                        
                        Button(action: {
                            
                            updateProduct()
                            
                        }) {
                            Text("Actualizar")
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.borderedProminent)
                        .tint(Color.accentColor)
                    }
                    .padding(.top, 30)
                }
            }
        }
        .padding()
        .onAppear {
            amount = product.amount
        }
    }
    
    private func updateProduct() {
        withAnimation {
            loading = true
        }
        
        let data = [
            "amount" : amount,
            "id" : product.id
        ]
        
        api.fetch(url: "shopping/update", method: "PUT", body: data, token: user!.token, ofType: ShoppingModResponse.self) { res, status in
            withAnimation {
                loading = false
            }
            
            if status {
                if res!.status == "success" {
                    if amount == 0 {
                        context.delete(product)
                        try! context.save()
                        
                        var est: FetchDescriptor<CartSD> {
                            return FetchDescriptor<CartSD>()
                        }
                        
                        let query = try! context.fetch(est)
                        
                        query.forEach { cart in
                            if cart.products.isEmpty {
                                context.delete(cart)
                            }
                        }
                    } else {
                        product.amount = amount
                    }
                }
                
                try! context.save()
                isPresented = false
            }
        }
    }
}
