//
//  Index.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 27/03/25.
//

import SwiftUI

struct Index: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var isBeyondZero: Bool = false
    @StateObject var viewModel = IndexViewModel.shared
    @ObservedObject var router = NavigationManager.shared
    
    func getOffsetY(basedOn geo: GeometryProxy) -> CGFloat {
            let minY = geo.frame(in: .global).minY
            
            let emptySpaceAboveSheet: CGFloat = 100
            if minY <= emptySpaceAboveSheet {
                return 0
            }
            return -minY + emptySpaceAboveSheet
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            HStack {
                Image(isBeyondZero ? .logoDark : .apprisaBlack)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 30)
                
                Spacer()
                
                Button(action: {
                    router.navigateSignOutTo(.Login)
                }) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 30))
                }
            }
            .padding()
            .background(isBeyondZero ? AnyShapeStyle(Color.clear) : AnyShapeStyle(Material.bar))
            .frame(width: Screen.width)
            .zIndex(10)
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 30) {
                    GeometryReader { imageGeo in
                        ZStack {
                            ZStack {
                                Color.black.opacity(0.45)
                                    .offset(x: 0, y: -10)
                                    .frame(width: Screen.width, height: Screen.height + 100)
                                    .zIndex(2)
                                
                                Image(.banner1)
                                    .offset(x: 0, y: -100)
                                    .frame(width: Screen.width, height: 500)
                                
                                VStack(alignment: .leading, spacing: 20) {
                                    VStack {
                                        Text("Hazlo hoy,")
                                        Text("Hazlo fácil")
                                    }
                                    .foregroundStyle(.white)
                                    .font(.largeTitle.bold())
                                    
                                    Text("¡Hazlo Súbito!")
                                        .font(.largeTitle.bold())
                                        .foregroundStyle(.accent)
                                    
                                    Text("Todo lo encuentras en Súbito")
                                        .foregroundStyle(.white)
                                }
                                .padding()
                                .frame(width: Screen.width, alignment: .leading)
                                .zIndex(3)
                            }
                            .frame(maxWidth: Screen.width, maxHeight: (Screen.height * 0.8))
                        }
                        .offset(x: 0, y: self.getOffsetY(basedOn: imageGeo))
                    }
                    .frame(width: Screen.width, height: (Screen.height * 0.6))
                    .scaledToFill()
                    
                    VStack {
                        HStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                if viewModel.categories.count > 0 {
                                    HStack {
                                        ForEach(viewModel.categories) { item in
                                            Category(
                                                category: item
                                            )
                                            .padding(
                                                EdgeInsets(
                                                    top: 0, leading: 5,
                                                    bottom: 0,
                                                    trailing: 5))
                                        }
                                    }
                                } else {
                                    HStack {
                                        ForEach(0..<10) { _ in
                                            SkeletonCellView(
                                                width: 65, height: 65
                                            )
                                            .padding(
                                                EdgeInsets(
                                                    top: 0, leading: 5,
                                                    bottom: 0,
                                                    trailing: 5))
                                        }
                                    }
                                    .blinking(duration: 0.75)
                                }
                            }
                        }
                        .padding()
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Spacer(minLength: 30)
                            
                            Text("Top marcas y cadenas de establecimientos")
                                .font(.title.bold())
                            
                            Text("Descubre una amplia variedad de productos y servicios en las mejores marcas y cadenas de establecimientos de Puebla. ¡Explora todo lo que Súbito tiene para ofrecerte!")
                            
                            VStack(spacing: 15) {
                                if viewModel.items.count > 0 {
                                    ForEach(viewModel.items) { item in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 5){
                                                Text(item.title)
                                                    .font(.title3.bold())
                                                
                                                Text(item.address)
                                                    .lineLimit(2)
                                            }
                                        }
                                        .padding()
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.accentColor, lineWidth: 1)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            
                            Spacer(minLength: 50)
                        }
                        .padding()
                        .frame(width: Screen.width)
                        .background(Color.accentColor.opacity(colorScheme == .dark ? 0.2 : 0.1))
                    }
                    .background(colorScheme == .light ? Color.white : Color.black)
                }
                .background(GeometryReader { reader in
                    Color.clear.preference(key: ViewOffsetKey.self, value: reader.frame(in: .named("scroll")).minY)
                })
            }
            .coordinateSpace(name: "scroll")
            .ignoresSafeArea()
            .onPreferenceChange(ViewOffsetKey.self) { value in
                if value >= 0.0 {
                    withAnimation {
                        isBeyondZero = true
                    }
                } else {
                    withAnimation {
                        isBeyondZero = false
                    }
                }
            }
        }
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

#Preview {
    Index()
}
