//
//  EatsComponent.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 01/11/24.
//

import SwiftUI

struct HomePage: View {
    
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State private var index = 1
    @State private var selectedNum: String = ""
    @State private var selectedRestaurant: String = ""
    
    let ads = [
        "https://historias.starbucks.com/_next/image/?url=https%3A%2F%2Fstories.starbucks.com%2Fuploads%2Fsites%2F21%2F2024%2F05%2Fvoto_1440x700-copia.jpg&w=3840&q=75",
        "https://img2.storyblok.com/1220x686/filters:format(webp)/f/102932/1240x697/d9eec535c0/mcdonalds-mmm.png",
        "https://pbs.twimg.com/media/EqSSBWfXUAEcewv.jpg:large"
    ]
    
    var body: some View {
        LazyVStack{
            VStack{
                Text("¡Prueba algo nuevo!")
                    .font(.title2)
                    .bold()
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing)
            
            ZStack{
                VStack{
                    
                    HStack{
                        GeometryReader { proxy in
                            TabView(selection: $selectedNum){
                                ForEach(ads, id: \.self) { url in
                                    AsyncImage(url: URL(string: url)){ image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 150)
                                            .clipShape(RoundedRectangle(cornerRadius: 30))
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        
                                    } placeholder: {
                                        ProgressView()
                                            .frame(height: 150)
                                            .clipShape(RoundedRectangle(cornerRadius: 30))
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    }
                                }
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .onReceive(timer, perform: { _ in
                                withAnimation {
                                    index = index < ads.count ? index + 1 : 1
                                    selectedNum = ads[index - 1]
                                }
                            })
                        }
                        .frame(height: 150)
                    }
                }
            }
        }
        .padding(.leading)
        .padding(.trailing)
        
    }
}
