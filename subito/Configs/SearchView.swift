//
//  SearchView.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 03/01/25.
//

import Foundation
import SwiftUI

struct SearchView<Content: View>: View {
    @Environment(\.isSearching) var isSearching
    let content: (Bool) -> Content
    
    var body: some View {
        content(isSearching)
    }
    
    init(@ViewBuilder content: @escaping (Bool) -> Content){
        self.content = content
    }
}
