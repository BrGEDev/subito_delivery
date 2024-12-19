//
//  PaymentMethod.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 16/12/24.
//

import SwiftData
import SwiftUI
import Combine

struct CardView: View {
    @Environment(\.colorScheme) var colorScheme
    var card: CardSD
    
    var body: some View {
        HStack{
            Image(card.card_type == "Visa" ? .visa : (card.card_type == "MasterCard" ? .mastercard : .american))
                .resizable()
                .frame(maxWidth: 30, maxHeight: 25)
                .scaledToFill()
            
            VStack(alignment: .leading) {
                Text("\(card.card_type) \(card.last_four)")
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
                    .bold()
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding([.leading, .trailing], 10)
        .padding([.top, .bottom])
        .background(card.status == true ? Color.accentColor.opacity(0.5) : (colorScheme == .dark ? .black.opacity(0.35) : .white))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .clipped()
        .padding(.bottom, 8)
    }
}

struct CVVCode: View {
    @Environment(\.dismiss)var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext)var contextModel
    @StateObject var api: ApiCaller = ApiCaller()
    @Query(sort:\CardSD.id, order: .forward) var cards: [CardSD]
    
    @State var title: String = "Código de seguridad"
    @State var cvv: String = ""
    @Binding var alert: Bool
    var selectCard: CardSD?
    
    private func limitText(_ upper: Int){
        if cvv.count > upper {
            cvv = String(cvv.prefix(upper))
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SecureField("CVV", text: $cvv)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(
                        colorScheme == .dark
                            ? Color.white.opacity(0.1).cornerRadius(20)
                            : Color.black.opacity(0.06).cornerRadius(20)
                    )
                    .keyboardType(.numberPad)
                    .onReceive(Just(cvv)){ _ in
                        limitText(4)
                    }

                Button(action: {
                    if cvv != "" {
                        if cvv.count < 3 {
                            alert = true
                        } else {
                            selectCard(cardselect: selectCard!)
                        }
                    } else {
                        alert = true
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
                        message: Text("Debe ingresar el código CVV de su tarjeta"),
                        dismissButton: .default(Text("Aceptar")))
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PaymentMethod: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss)var dismiss
    @Environment(\.modelContext)var contextModel
    @StateObject var api: ApiCaller = ApiCaller()
    
    @State var selected: CardSD?
    
    @State var alert: Bool = false
    @Query var userSD: [UserSD]
    var user: UserSD? { userSD.first }
    
    @Query(sort:\CardSD.id, order: .forward) var cards: [CardSD]
    @State var webview: Bool = false
    @State var loading: Bool = false
    
    
    var body: some View {
        VStack{
            if cards.count != 0{
                List {
                    ForEach(cards) { card in
                        CardView(card: card)
                        .onTapGesture {
                            if card.token == nil {
                                selected = card
                                loading = true
                            } else {
                                selectCard(cardselect: card)
                            }
                        }
                        .padding([.leading, .trailing])
                        .listRowBackground(Color.white.opacity(0))
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listSectionSeparator(.hidden)
                    }
                    .onDelete(perform: deleteCard)
                 
                }
                .frame(maxWidth: .infinity)
                .listStyle(.grouped)
            } else {
                VStack{
                    Image(.logo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                    
                    Text("No tiene tarjetas registradas")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: 300, maxHeight:.infinity)
                .padding()
            }
            
            VStack{
                Button(action: {
                    webview = true
                }) {
                    Label("Agregar tarjeta", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.black)
                .frame(height: 50)
                .background(.accent)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 10)
            }
            .padding()
        }
        .sheet(isPresented: $webview, onDismiss: {getPaymentMethod()}){
            LoadWebView(url: URL(string: "https://ti-lexa.tech/#/auth/save-card?token=\(user!.token)")!)
            .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $loading, onDismiss: {dismiss()}){
            CVVCode(alert: $alert, selectCard: selected)
            .presentationDetents([.height(280)])
            .presentationBackgroundInteraction(.disabled)
            .interactiveDismissDisabled(true)
            .presentationCornerRadius(35)
        }
        .toolbar{
            if cards.count != 0 {
                ToolbarItem(placement: .navigationBarTrailing){
                    EditButton()
                }
            }
        }
        .navigationTitle("Método de pago")
        .onAppear{
            getPaymentMethod()
        }
        .refreshable {
            getPaymentMethod()
        }
    }
}

#Preview {
    PaymentMethod()
        .modelContainer(for: [UserSD.self, DirectionSD.self, CardSD.self, CartSD.self])
}