//
//  DeliveryLiveActivity.swift
//  Delivery
//
//  Created by Brandon Guerra Espinoza  on 25/11/24.
//

import ActivityKit
import WidgetKit
import SwiftUI


@main
struct DeliveryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack(alignment: .leading, spacing: 20){
                HStack{
                    Image(.subito)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 20)
                    
                    Spacer()
                    
                    Text(context.state.DeliveryState.rawValue)
                        .foregroundStyle(.secondary)
                        .font(.system(size: 16))
                }
                
                HStack{
                    Image(.repartidor2)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 60, maxHeight: 60)
                        .padding(.trailing, 5)
                    
                    Text("Tu pedido de \(context.state.establishment) está en camino")
                        .bold()
                        .font(.title3)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                VStack(alignment: .leading){
                    Text("Tiempo de entrega estimado: \(context.state.estimated)")
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(.repartidor2)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 40, maxHeight: 40)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Repartidor Súbito 1")
                        .multilineTextAlignment(.trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading){
                        HStack{
                            Text(context.state.DeliveryState.rawValue)
                                .bold()
                            
                            Spacer()
                            
                            Text("Llegando en \(context.state.time)")
                                .foregroundStyle(.secondary)
                        }
                        
                        Button(action: {}) {
                            Label("Ver mi pedido", systemImage: "basket.fill")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(5)
                        }
                        .tint(.accent)
                        
                    }
                }
            } compactLeading: {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            } compactTrailing: {
                Text(context.state.time)
            } minimal: {
                Image(.logo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
            }
        }
    }
}

extension DeliveryAttributes {
    fileprivate static var preview: DeliveryAttributes {
        DeliveryAttributes()
    }
}

extension DeliveryAttributes.ContentState {
    fileprivate static var smiley: DeliveryAttributes.ContentState {
        DeliveryAttributes.ContentState(DeliveryState: .pending, establishment: "Toks", estimated: "10:11 p.m.", time: "8 min")
     }
}

#Preview("Notification", as: .content, using: DeliveryAttributes.preview) {
   DeliveryLiveActivity()
} contentStates: {
    DeliveryAttributes.ContentState.smiley
}
