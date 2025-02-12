//
//  SearchModel.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 11/02/25.
//

import Foundation

struct SearchResponse: Decodable {
    let status: String
    let message: String
    let data: SearchData?
}

struct SearchData: Decodable {
    var type_establishments: [TypeEstablishmentsModel]?
    var establishments: [Establishments]?
    var products: [Product]?
}
