//
//  AddCard.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 12/02/25.
//

import Combine
import SwiftUI

struct AddCard: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var api: ApiCaller = ApiCaller()
    let user: UserSD

    @State var name: String = ""
    @State var card: String = ""
    @State var cvv: String = ""
    @State var date: Date? = nil
    @State var convertedDate: String = "MM/YYYY"

    @State var errorExpiration: Bool = false
    @State var alert: Bool = false
    @State var progress: Bool = false
    @State private var rotation: Double = 0

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        ZStack {
                            Color.accentColor.opacity(0.2).cornerRadius(25)

                            VStack(spacing: 50) {

                                HStack {
                                    Spacer()

                                    Image(.apprisaBlack)
                                        .resizable()
                                        .frame(maxWidth: 100, maxHeight: 25)
                                        .scaledToFit()
                                }

                                VStack(alignment: .leading) {
                                    Text(
                                        card == ""
                                            ? "XXXX XXXX XXXX XXXX"
                                            : card.applyPattern()
                                    )
                                    .font(.title2.bold())
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                HStack {
                                    Text(
                                        name == ""
                                            ? "Titular de la tarjeta" : name)

                                    Spacer()

                                    Text(convertedDate)
                                        .foregroundStyle(
                                            errorExpiration
                                                ? Color.red : Color.black)
                                }
                            }
                            .padding()
                        }

                        Spacer(minLength: 50)

                        TextField("Número de tarjeta", text: $card)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(.ultraThinMaterial)
                            .keyboardType(.numberPad)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .onReceive(Just(card)) { _ in
                                limitCardText(16)
                            }

                        VStack(alignment: .leading) {
                            PickerField("MM/YYYY", selectionIndex: $date)
                                .padding()
                                .frame(height: 50)
                                .background(
                                    errorExpiration
                                        ? AnyShapeStyle(Color.red.opacity(0.2))
                                        : AnyShapeStyle(.ultraThinMaterial)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .onChange(of: date ?? Date.now) { _, newValue in
                                    convertedDate = convertDate(date: newValue)

                                    if newValue >= Date.now {
                                        withAnimation {
                                            errorExpiration = false
                                        }
                                    } else {
                                        withAnimation {
                                            errorExpiration = true
                                        }
                                    }
                                }
                            if errorExpiration {
                                Text("La fecha de vencimiento es inválida")
                                    .foregroundColor(.red)
                                    .font(.footnote)
                            }
                        }

                        SecureField("Código de seguridad", text: $cvv)
                            .padding()
                            .frame(height: 50)
                            .background(.ultraThinMaterial)
                            .keyboardType(.numberPad)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .onReceive(Just(cvv)) { _ in
                                limitText(4)
                            }

                        TextField("Nombre del titular", text: $name)
                            .padding()
                            .frame(height: 50)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .padding()
                }

                Button(action: {
                    createCard()
                }) {
                    Text("Guardar tarjeta")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(.system(size: 18))
                        .bold()
                }
                .foregroundColor(.black)
                .frame(height: 50)
                .background(
                    calcEnabled()
                        ? Color.accentColor.opacity(0.6) : Color.accentColor
                )
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 10)
                .disabled(calcEnabled())
                .padding()
            }
            .sheet(isPresented: $progress){
                VStack{
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
                    
                    Text("Agregando tarjeta...")
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
            .alert(isPresented: $alert) {
                Alert(
                    title: Text("Error"),
                    message: Text(
                        "Ocurrió un error al agregar la tarjeta, por favor intente de nuevo más tarde o consulte con su institución bancaria."
                    ), dismissButton: .default(Text("Aceptar")))
            }
            .navigationTitle("Agregar tarjeta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Text("Cancelar")
                    }
                }
            }
        }
    }

    private func convertDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/YYYY"
        return formatter.string(from: date)
    }

    private func limitText(_ upper: Int) {
        if cvv.count > upper {
            cvv = String(cvv.prefix(upper))
        }
    }

    private func limitCardText(_ upper: Int) {
        if card.count > upper {
            card = String(card.prefix(upper))
        }
    }

    private func calcEnabled() -> Bool {
        if cvv.isEmpty || name.isEmpty || errorExpiration || card.isEmpty {
            return true
        }
        return false
    }

    private func createCard() {
        progress = true
        let expiricy = convertDate(date: date!).split(separator: "/")

        let mercadoPagoData: [String: Any] = [
            "securityCode": cvv,
            "expirationYear": expiricy[1],
            "expirationMonth": expiricy[0],
            "cardNumber": card,
            "cardHolder": [
                "name": name
            ],
        ]

        api.mercagoPago(
            url: "card_tokens", method: "POST", body: mercadoPagoData,
            ofType: CardTokens.self
        ) { res, status in
            if status {
                if res!.status == "active" {
                    let token = [
                        "token": res!.id
                    ]
                    
                    print(res!.id, user.token)

                    api.fetch(
                        url: "savePayment", method: "POST", body: token,
                        token: user.token, ofType: PaymentsResponse.self
                    ) { res, status in
                        
                        if(status) {
                            
                            if res!.status == "success" {
                                progress = false
                                dismiss()
                            }
                            
                        } else {
                            progress = false
                            alert = true
                        }
                    }
                } else {
                    progress = false
                    alert = true
                }
            } else {
                progress = false
                alert = true
            }
        }

    }
}
