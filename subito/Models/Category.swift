//
//  Category.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 25/10/24.
//

import SwiftUI

struct ModelCategories: Identifiable {
    let id: Int
    var image: String
    var texto: String
}

struct TypeEstablishmentsResponse: Codable {
    let status: String
    let message: String
    let data: [TypeEstablishmentsModel]?
}

struct TypeEstablishmentsModel: Codable {
    let dc_id: Int
    let dc_name: String
    let dc_path: String
}

/* Categorías de productos del establecimiento */

struct ProductCategoryResponse: Codable {
    var status: String
    var message: String
    var data: [ProductCategory]?
}

struct ProductCategory: Codable {
    var pg_id: Int
    var pg_name: String
    var pg_description: String
    var pg_establishments_id: String
    var created_at: String?
    var updated_at: String?
}
