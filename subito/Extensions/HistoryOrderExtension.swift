//
//  HistoryOrderExtension.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 13/03/25.
//

import Foundation
import SwiftUI

extension HistoryOrder {
    var ListView: some View {
        LazyVStack(spacing: 10) {
            ForEach(historyModel.orders.sorted(by: { it,_ in it.status == selectSort }), id: \.id_order) { order in
                NavigationLink {
                    HistoryOrderDetail(order: order)
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(order.no_order)
                                .lineLimit(1)
                                .truncationMode(.tail)

                            Spacer()

                            Text(order.status)
                        }
                        
                        Text(order.name_restaurant)
                            .font(.headline.bold())

                        Label(
                            title: {
                                Text(
                                    dateFromString(string: order.created_at),
                                    style: .date
                                ).font(.caption)
                            },
                            icon: {
                                Image(systemName: "clock.fill").font(.caption)
                            })
                    }
                }
                .foregroundStyle(Color.primary)
                .padding()
                .background(Material.bar)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .clipped()
            }
        }
        .padding()
    }
    
    var GridView: some View {
        LazyVGrid(columns: adaptiveColumn, spacing: 10) {
            ForEach(historyModel.orders.sorted(by: { it,_ in it.status == selectSort }), id: \.id_order) { order in
                NavigationLink {
                    HistoryOrderDetail(order: order)
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(order.status)
                        
                        Text(order.name_restaurant)
                            .font(.headline.bold())
                        
                        Label(
                            title: {
                                Text(
                                    dateFromString(string: order.created_at),
                                    style: .date
                                ).font(.caption)
                            },
                            icon: {
                                Image(systemName: "clock.fill").font(.caption)
                            })
                        
                        Text(order.no_order)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .font(.caption)
                    }
                }
                .foregroundStyle(Color.primary)
                .padding()
                .frame(width: Screen.width * 0.45)
                .background(Material.bar)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .clipped()
            }
        }
        .padding()
    }
    
    func dateFromString(string: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        return formatter.date(from: string)!
    }
}
