//
//  UserStateModel.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 09/09/24.
//

import Foundation
import SwiftData
import SwiftUI

enum UserStateError: Error {
    case signInError, signOutError
}

@MainActor
class UserStateModel: ObservableObject {
    private var models: [any PersistentModel.Type] = [
        UserSD.self, DirectionSD.self, CartSD.self, ProductsSD.self,
        CardSD.self, TrackingSD.self,
    ]

    lazy public var container: ModelContainer = {
        let schema = Schema(models)

        let conf = ModelConfiguration(
            schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [conf])
        } catch {
            fatalError(
                "Could not create ModelContainer: \(error.localizedDescription)"
            )
        }
    }()

    lazy public var context: ModelContext = ModelContext(container)

    @Published var loggedIn: Bool = false
    @Published var isBusy: Bool = false
    @Published var alert: Bool = false
    @Published var message: String = ""
    @Published var userData: LoginInfo?

    private var login: ApiCaller = ApiCaller()

    init() {
        context.autosaveEnabled = false

        let user = FetchDescriptor<UserSD>()
        let userQuery = try! self.context.fetch(user).first
        loggedIn = userQuery == nil ? false : true

        if userQuery != nil {
            UserDefaults().set(userQuery!.token, forKey: "tokenUser")
            loadCart(token: userQuery!.token)
        }
    }

    func signIn(user: String, pass: String) async -> Result<Bool, UserStateError> {
        withAnimation {
            isBusy = true
        }

        var response: Bool = false

        let data = [
            "email": user,
            "password": pass,
        ]

        login.fetch(
            url: "login", method: "POST", body: data, ofType: Login.self
        ) { res, status in
            if status {
                if res!.status == "error" {
                    
                    withAnimation {
                        self.loggedIn = false
                        self.isBusy = false
                    }
                    
                    self.alert = true
                    self.message = "Usuario y/o contraseña incorrectos."

                    response = false
                } else {
                    let us = res!.data?.user

                    do {
                        self.context.insert(
                            UserSD(
                                id: us!.ua_id, name: us!.ua_name,
                                lastName: us!.ua_lastname, email: us!.ua_email,
                                phone: us!.ua_phone ?? "",
                                birthday: us!.ua_birthday ?? "",
                                token: res!.data!.token
                            )
                        )

                        UserDefaults().set(res!.data!.token, forKey: "tokenUser")
                        self.loadCart(token: res!.data!.token)

                        try self.context.save()

                        withAnimation {
                            self.loggedIn = true
                            self.isBusy = false
                        }

                        response = true
                    } catch {
                        withAnimation {
                            self.loggedIn = true
                            self.isBusy = false
                        }
                    }
                }
            }
        }

        if response {
            return .success(response)
        } else {
            return .failure(.signInError)
        }
    }

    func signOut() async -> Result<Bool, UserStateError> {

        isBusy = true
        
        var response: Bool = false

        let user = FetchDescriptor<UserSD>()
        let userQuery = try! self.context.fetch(user).first!.token

        login.fetch(
            url: "logout", method: "POST", token: userQuery,
            ofType: LogoutResponse.self
        ) { res, status in
            if status {
                if res!.status == "success" {

                    for model in self.models {
                        do {
                            try self.context.delete(model: model)
                        } catch {
                            print("Error deleting \(model)", error)
                        }
                    }

                    withAnimation {
                        self.loggedIn = false
                        self.isBusy = false
                    }

                    response = true
                } else {
                    response = false
                }
            } else {
                withAnimation {
                    self.isBusy = false
                }
                response = false
            }
        }

        if response {
            return .success(true)
        } else {
            return .failure(.signOutError)
        }
    }

    private func loadCart(token: String) {
        login.fetch(
            url: "payment-methods", method: "POST", token: token,
            ofType: PaymentMethodResponse.self
        ) { res, status in
            if status {
                if res!.status == "success" {
                    if res!.data!.count != 0 {
                        for card in res!.data! {
                            let newCard = CardSD(
                                id: card.id, last_four: card.last_four_digits,
                                card_type: card.issuer.name ?? card.payment_method.name,
                                expiry:
                                    "\(card.expiration_month)/\(card.expiration_year)",
                                brand: card.payment_method.secure_thumbnail,
                                name: card.cardholder.name ?? "",
                                token: nil)
                            
                            self.context.insert(newCard)
                        }
                        
                        try! self.context.save()
                    }
                }
            }
        }
        
        login.fetch(url: "shopping/get", method: "GET", token: token, ofType: ShoppingResponse.self) { res, status in
            if status {
                if res!.status == "success" {
                    try! self.context.delete(model: CartSD.self)
                    let data = res!.data

                    if data != nil {
                        let cart = CartSD(
                            id: Int(data!.establishment_id)!,
                            establishment: data!.order.products[0].name_restaurant,
                            latitude: data!.establishment_latitude,
                            longitude: data!.establishment_longitude
                        )

                        for product in data!.order.products {
                            let producto = ProductsSD(
                                id: Int(product.pd_id)!, product: product.pd_name,
                                image: product.pd_image, descript: "",
                                unit_price: Float(product.pd_unit_price)!,
                                amount: Int(product.pd_quantity)!
                            )

                            cart.products.append(producto)
                        }

                        self.context.insert(cart)
                        try! self.context.save()
                    }
                }
            }
        }
    }
}
