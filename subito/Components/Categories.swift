//
//  Categories.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 25/10/24.
//

import SwiftUI

struct Category: View{
    @Environment(\.colorScheme) var colorScheme
    @State var category: ModelCategories
    @ObservedObject var router = NavigationManager.shared

    var body: some View {
        Button(action: {
            router.navigateTo(.Establishment(categoryTitle: category.texto, id: category.id))
        }){
            VStack{
                AsyncImageCache(url: URL(string: category.image)){ image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 65, height: 65)
                } placeholder: {
                    ProgressView()
                        .frame(width: 65, height: 65)
                }
                    
                Text(category.texto)
                    .lineLimit(1)
                    .font(.system(size: 15))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            }
        }
    }
}
