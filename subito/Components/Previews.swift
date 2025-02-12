//
//  Previews.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 26/12/24.
//

import SwiftUI

struct PreviewProduct: View {
    var data: Product
    
    var body: some View {
        ZStack(alignment: .top){
            VStack{
                AsyncImageCache(url: URL(string: data.pd_image ?? "")){ image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
            }
            .frame(width: Screen.width, height: 500, alignment: .top)
            
            HStack(alignment: .bottom){
                VStack{
                    Spacer()
                    
                    VStack(spacing: 20){
                        Text(data.pd_name)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .font(.title)
                            .bold()
                        
                        Text(data.pd_description)
                            .lineLimit(2)
                            .truncationMode(.tail)
                        
                        HStack{
                            Text(Float(data.pd_unit_price)!, format: .currency(code: "MXN"))
                                .font(.system(size: 20))
                            
                            Spacer()
                            
                            Text("\(Image(systemName: "shippingbox")) \(data.pd_quantity ?? "0")")
                                .font(.system(size: 20))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Material.thin)
                }
            }
        }
        .frame(minWidth: Screen.width, maxWidth: Screen.width, minHeight: 300, maxHeight: .infinity)
    }
}
