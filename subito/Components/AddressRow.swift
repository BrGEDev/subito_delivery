//
//  AddressRow.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 29/11/24.
//

import SwiftUI

struct AddressRow: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var address: AddressResult
    @State var type_icon = ""
    
    var body: some View {
        HStack{
            Image(systemName: type_icon == "from" ? "location.fill" : "mappin")
                .frame(width: 20, height: 20)
                .padding([.trailing, .leading], 5)
            
            VStack(alignment:.leading){
                Text(address.title)
                    .multilineTextAlignment(.leading)
                    .bold()
                    .font(.headline)
                
                Text(address.subtitle)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding([.leading], 10)
        .padding([.top, .bottom])
        .padding(.bottom, 8)
    }
}

struct AddressList: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var address: DirectionSD
    
    var body: some View {
        HStack{
            Image(systemName: "mappin")
                .frame(width: 20, height: 20)
                .padding([.trailing, .leading], 5)
            
            VStack(alignment:.leading){
                Text(address.id == 0 ? "Ubicación actual" : (address.name != "" ? address.name : address.full_address))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
                    .bold()
                    .font(.headline)
                
                Text(address.full_address)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .trailing], 10)
        .padding([.top, .bottom])
        .padding(.bottom, 8)
    }
}

