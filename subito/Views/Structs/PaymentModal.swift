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
                    AsyncImage(url: URL(string: product.image)) { image in
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
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var context
    @StateObject var api: ApiCaller = ApiCaller()
    
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

    @State var segment: Int = 0
    @State var propina: Int = 0
    @State var prepropina: Float = 0
    @State var payment: Float = 0
    @State var subtotal: Float = 0
    @State var envio: Float = 40
    @State var km: Double = 0

    @State var modalPropina: Bool = false
    @State var alert: Bool = false
    @State var cvvCode: Bool = false

    @State var currentDeliveryState: DeliveryState = .pending
    @State var activityIdentifier: String = ""

    var body: some View {
        VStack {
            List {
                Section(header: Text("Dirección de envío")) {
                    NavigationLink(
                        destination:
                            DirectionsModal()
                    ) {
                        Label(
                            directionSelected?.full_address
                                ?? "Selecciona una dirección",
                            systemImage: "mappin.circle.fill")
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
                        Label(paymentsSelected == nil ? "Selecciona un método de pago" : "\(paymentsSelected!.card_type) \(paymentsSelected!.last_four)", systemImage: "creditcard.fill")
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
                        VStack(alignment: .leading){
                            Text("Costo de envío")
                            Text(Measurement(value: km, unit: UnitLength.kilometers), format: .measurement(width: .abbreviated))
                                .font(.footnote)
                        }

                        Spacer()

                        Text(envio, format: .currency(code: "MXN"))
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

            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)

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
                .background(paymentsSelected == nil ? Color.accentColor.opacity(0.8) : Color.accentColor)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 10)
                .disabled(paymentsSelected == nil ? true : false)
            }
            .padding()
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
        .sheet(isPresented: $cvvCode){
            CVVCode(title: "Ingrese su CVV antes de continuar", alert: $alert, selectCard: paymentsSelected)
            .presentationDetents([.height(280)])
            .presentationBackgroundInteraction(.disabled)
            .interactiveDismissDisabled(true)
            .presentationCornerRadius(35)
        }
        .navigationBarTitle("Enviar pedido")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            calcDistance()
            loadPayment()
            loadTaxes()
        }
        .onChange(of: segment) {
            loadTaxes()
        }
        .onChange(of: directionSelected){
            calcDistance()
        }
    }
}

#Preview {
    Eats()
        .modelContainer(for: [UserSD.self, DirectionSD.self, ProductsSD.self, CardSD.self, CartSD.self])
}