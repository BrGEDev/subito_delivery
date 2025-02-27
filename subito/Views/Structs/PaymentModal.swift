//
//  PaymentModal.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 25/11/24.
//

import Combine
import SwiftData
import SwiftUI

struct productoPayment: View {
    @Environment(\.modelContext) var context
    @State var product: ProductsSD
    var establishment: Int

    var body: some View {
        VStack {
            HStack {
                VStack {
                    AsyncImageCache(url: URL(string: product.image)) { image in
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
            }
            .padding()
        }
    }
}

struct PaymentModal: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var context
    @StateObject var api: ApiCaller = ApiCaller()
    @StateObject var socket = SocketService.socketClient

    @Binding var isPresented: Bool
    @Binding var pending: Bool

    @Query var establishments: [CartSD]
    @Query(
        filter: #Predicate<DirectionSD> { direction in
            direction.status == true
        }) var directions: [DirectionSD]
    var directionSelected: DirectionSD? { directions.first }
    @Query(
        filter: #Predicate<CardSD> { card in
            card.status == true
        }) var payments: [CardSD]
    var paymentsSelected: CardSD? { payments.first }

    @State var segment: Int = 0
    @State var propina: Int = 0
    @State var prepropina: Float = 0
    @State var payment: Float = 0
    @State var subtotal: Float = 0
    @State var envio: Float = 40
    @State var km: Double = 0
    @State var estimatedTime: String?
    @State var detail: String = ""
    @State var km_base: Double = 7
    @State var price_base_km: Double = 70
    @State var price_km_extra: Double = 4
    @State var percent: Double = 0

    @State var modalPropina: Bool = false
    @State var alert: Bool = false
    @State var error: Bool = false
    @State var cvvCode: Bool = false
    @State var progress: Bool = false

    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State var directionModal: Bool = false
    
    @State var loading: Bool = true

    var body: some View {
        if loading {
            ZStack {
                Image(.fondo2)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()

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
                        
                        Text("Preparando tu pedido...")
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .padding()
                    }

                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear {
                prePurchase()
            }
        } else {
            NavigationView{
                List {
                    Section(header: Text("Dirección de envío")) {
                        Button(action: {
                            directionModal = true
                        }) {
                            Label {
                                Text(directionSelected?.full_address ?? "Selecciona una dirección")
                            } icon: {
                                Image(systemName:  "mappin.circle.fill")
                                    .foregroundStyle(Color.accentColor)
                            }
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listSectionSeparator(.hidden)
                    .listRowBackground(Color.white.opacity(0))
                    
                    Section(header: Text("Método de pago")) {
                        NavigationLink(
                            destination:
                                PaymentMethod()
                        ) {
                            Label(
                                paymentsSelected == nil
                                ? "Selecciona un método de pago"
                                : "\(paymentsSelected!.card_type) \(paymentsSelected!.last_four)",
                                systemImage: "creditcard.fill")
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listSectionSeparator(.hidden)
                    .listRowBackground(Color.white.opacity(0))
                    
                    Section(
                        header: Text("¿Deseas agregar propina?"),
                        footer: Text(
                            "Un apoyo para tu repartidor Súbito, ¡recibirá el 100% de la cantidad!"
                        )
                    ) {
                        Picker("Propina", selection: $segment) {
                            Text("5%").tag(5)
                            Text("10%").tag(10)
                            Text("15%").tag(15)
                            Text("20%").tag(20)
                            Text(segment != -1 ? "Otro" : "Editar").tag(-1)
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                        .colorMultiply(Color.accentColor)
                    }
                    .listRowSeparator(.hidden)
                    .listSectionSeparator(.hidden)
                    .listRowBackground(Color.white.opacity(0))
                    
                    ForEach(establishments) { est in
                        VStack {
                            HStack {
                                Text(est.establishment)
                                    .font(.title3)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                
                                Spacer()
                            }
                            .padding()
                            
                            ForEach(est.products) { prod in
                                productoPayment(
                                    product: prod, establishment: est.id)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Material.ultraThin)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.black.opacity(0.15), radius: 10)
                        .listRowBackground(Color.white.opacity(0))
                        .listRowSeparator(.hidden)
                        .listSectionSeparator(.hidden)
                    }
                    
                    Section {
                        HStack {
                            Text("Total de productos")
                            
                            Spacer()
                            
                            Text(subtotal, format: .currency(code: "MXN"))
                        }
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Costo de envío")
                                Text(
                                    Measurement(value: km, unit: UnitLength.kilometers),
                                    format: .measurement(width: .abbreviated)
                                )
                                .font(.footnote)
                            }
                            
                            Spacer()
                            
                            if envio == 0 {
                                Text("Envío gratis").foregroundStyle(Color.green)
                            }
                            else {
                                Text(envio, format: .currency(code: "MXN"))
                            }
                        }
                        
                        if prepropina > 0 {
                            HStack {
                                Text("Propina")
                                
                                Spacer()
                                
                                Text(prepropina, format: .currency(code: "MXN"))
                            }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0))
                    .listRowSeparator(.hidden)
                    .listSectionSeparator(.hidden)
                    
                    Section(
                        header: Text("Detalles del pedido"),
                        footer: Text(
                            "Puedes especificar los detalles que necesites sobre tu pedido"
                        )
                    ) {
                        TextEditorWithPlaceholder(text: $detail)
                    }
                    .listRowBackground(Color.white.opacity(0))
                    .listRowSeparator(.hidden)
                    .listSectionSeparator(.hidden)
                }
                .listStyle(.grouped)
                .scrollContentBackground(.hidden)
                .navigationBarTitle("Enviar pedido")
                .navigationBarTitleDisplayMode(.inline)
                .safeAreaInset(edge: .bottom) {
                    VStack {
                        HStack {
                            Text("Total:")
                                .font(.largeTitle)
                                .bold()
                            
                            Spacer()
                            
                            Text(payment, format: .currency(code: "MXN"))
                                .font(.largeTitle)
                                .bold()
                        }
                        Button(action: {
                            buyCart()
                        }) {
                            Text("Continuar y pagar")
                                .padding()
                                .font(.system(size: 18))
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                        .frame(height: 50)
                        .background(
                            paymentsSelected == nil || directionSelected == nil
                            ? Color.accentColor.opacity(0.8) : Color.accentColor
                        )
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.2), radius: 10)
                        .disabled(
                            paymentsSelected == nil || directionSelected == nil
                            ? true : false)
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color.black : Color.white)
                }
                .sheet(isPresented: $modalPropina) {
                    NavigationView {
                        VStack {
                            TextField("Propina", value: $propina, format: .number)
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(width: 300, height: 50)
                                .background(
                                    colorScheme == .dark
                                    ? Color.white.opacity(0.1).cornerRadius(20)
                                    : Color.black.opacity(0.06).cornerRadius(20)
                                )
                                .keyboardType(.numberPad)
                                .onReceive(Just(propina)) { value in
                                    propina = value > 40 ? 40 : value
                                }
                            
                            Button(action: {
                                if propina <= 0 {
                                    alert = true
                                } else {
                                    modalPropina = false
                                    calcTax()
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
                                modalPropina = false
                                propina = 0
                                segment = 0
                                calcTax()
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
                    .presentationDetents([.height(280)])
                    .presentationBackgroundInteraction(.disabled)
                    .interactiveDismissDisabled(true)
                    .presentationCornerRadius(35)
                }
                .sheet(isPresented: $cvvCode) {
                    CVVCode(
                        title: "Ingrese su CVV antes de continuar", alert: $alert,
                        selectCard: paymentsSelected
                    )
                    .presentationDetents([.height(280)])
                    .presentationBackgroundInteraction(.disabled)
                    .interactiveDismissDisabled(true)
                    .presentationCornerRadius(35)
                }
                .sheet(isPresented: $directionModal) {
                    DirectionsModal()
                }
                .onChange(of: segment) {
                    loadTaxes()
                }
                .onChange(of: directionSelected) {
                    calcDistance()
                }
                .sheet(isPresented: $progress) {
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
                        
                        Text("Procesando tu pago...")
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
                .alert(isPresented: $error) {
                    Alert(
                        title: Text("Error"),
                        message: Text(
                            "Ha ocurrido un error procesando tu pago, por favor intenta de nuevo o contacta con tu banco emisor."
                        ), dismissButton: .default(Text("Aceptar")))
                }
            }
        }
    }
}
