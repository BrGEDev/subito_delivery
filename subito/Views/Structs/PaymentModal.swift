//
//  PaymentModal.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 25/11/24.
//

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
    
    @ObservedObject var router = NavigationManager.shared
    @ObservedObject var pendingOrderModel = PendingOrderModel.shared

    @Binding var isPresented: Bool

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

    @State var detail: String = ""
   
    @State var alert: Bool = false
    @State var error: Bool = false
    @State var cvvCode: Bool = false
    @State var progress: Bool = false

    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State var directionModal: Bool = false
        
    @ObservedObject var viewModel = PrePurchaseViewModel.shared

    var body: some View {
        if viewModel.loading {
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
        } else {
            NavigationView{
                List {
                    Group {
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
                        
                        Section(
                            header: Text("¿Deseas agregar propina?"),
                            footer: Text(
                                "Un apoyo para tu repartidor Súbito, ¡recibirá el 100% de la cantidad!"
                            )
                        ) {
                            PropinaPicker(segment: $viewModel.segment)
                        }
                        
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
                        }
                        
                        Section {
                            HStack {
                                Text("Total de productos")
                                
                                Spacer()
                                
                                Text(viewModel.subtotal, format: .currency(code: "MXN"))
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Costo de envío")
                                    Text(
                                        Measurement(value: viewModel.km, unit: UnitLength.kilometers),
                                        format: .measurement(width: .abbreviated)
                                    )
                                    .font(.footnote)
                                }
                                
                                Spacer()
                                
                                if viewModel.envio == 0 {
                                    Text("Envío gratis").foregroundStyle(Color.green)
                                }
                                else {
                                    Text(viewModel.envio, format: .currency(code: "MXN"))
                                }
                            }
                            
                            if viewModel.prepropina > 0 {
                                HStack {
                                    Text("Propina")
                                    
                                    Spacer()
                                    
                                    Text(viewModel.prepropina, format: .currency(code: "MXN"))
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
                            
                            Text(viewModel.payment, format: .currency(code: "MXN"))
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
                .sheet(isPresented: $viewModel.modalPropina) {
                    ModalPropina(alert: $alert)
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
                        
                        Text("Creando tu pedido...")
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
                .alert("Error", isPresented: $error) {
                    Text("Ha ocurrido un error creando tu pedido, por favor intente de nuevamente.")
                    
                    Button(role: .destructive, action: {
                        alert = false
                    }) {
                        Text("Aceptar")
                    }
                }
                .onChange(of: viewModel.segment) {
                    viewModel.loadTaxes()
                }
                .onChange(of: directionSelected) {
                    viewModel.calcDistance(directionSelected: directionSelected, establishments: establishments)
                }
                .onAppear {
                    viewModel.calcDistance(directionSelected: directionSelected, establishments: establishments)
                }
            }
        }
    }
}
