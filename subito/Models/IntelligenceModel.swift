//
//  IntelligenceModel.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 20/03/25.
//

struct FavResponse: Decodable {
    let status: String
    let message: String
    let data: FavData?
}

struct FavData: Decodable {
    let establecimiento: EstablecimientoFavData
    let productos: [ProductosFavData]
}

struct EstablecimientoFavData: Decodable {
    let id: String
    let nombre: String
    let logo: String
    let latitude: String
    let longitude: String
}

struct ProductosFavData: Decodable {
    let id: Int
    let nombre: String
    let precio: String
    let imagen: String
    let cantidadCompra: Int
    let promedioCompra: Int
    let vecesCompra: Int
}
