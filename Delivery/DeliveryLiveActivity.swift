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
            let image: ImageResource = context.state.DeliveryState == .pending || context.state.DeliveryState == .preparation ? .tienda : (context.state.DeliveryState == .inProgress ? .repartidor2 : .logo)
            
            VStack(alignment: .leading, spacing: 15){
                HStack{
                    Image(.subito)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 20)
                    
                    Spacer()
                    
                    Text(context.state.DeliveryState.rawValue.firstUppercased)
                        .foregroundStyle(.secondary)
                        .font(.system(size: 16))
                }
                
                HStack{
                    VStack {
                        Image(image)
                            .resizable()
                            .scaledToFill()
                            .padding(.trailing, 5)
                    }
                    .frame(maxWidth: 40, maxHeight: 40)
                    
                    VStack(alignment: .leading) {
                        Text("Tu pedido de \(context.state.establishment) está \(context.state.DeliveryState.rawValue)")
                            .bold()
                            .font(.title3)
                    }
                    .padding(.leading, 10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                
                VStack(alignment: .leading){
                    Text("Llegando \(context.state.estimated)")
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.secondary)
                }
                
                ProgressView(value: 30, total: 100).tint(.accent)
            }
            .padding()
            
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(.subito)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 80)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    let data = context.state
                    let image: ImageResource = data.DeliveryState == .pending || data.DeliveryState == .preparation ? .tienda : (data.DeliveryState == .inProgress ? .repartidor2 : .logo)
                    
                    VStack(alignment: .leading, spacing: 1){
                        HStack{
                            Text("Tu pedido está \(data.DeliveryState.rawValue)")
                                .bold()
                                .font(.system(size: 18))
                            
                            Spacer()
                            
                            Image(image)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: 40, maxHeight: 40)
                        }
                        
                        Text("Llegando \(context.state.estimated)")
                            .foregroundStyle(.secondary)
                            .bold()
                            .font(.system(size: 15))
                            .padding(.bottom, 15)
                        
                        ProgressView(value: 30, total: 100).tint(.accent)
                    }
                }
            } compactLeading: {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            } compactTrailing: {
                Text(context.state.estimated)
            } minimal: {
                Image(.logo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 25, height: 25)
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
        DeliveryAttributes.ContentState(DeliveryState: .pending, establishment: "Tacos Bbto", estimated: "10:11 p.m.", time: "8 min")
     }
}

extension StringProtocol {
    var firstUppercased: String { return prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { return prefix(1).capitalized + dropFirst() }
}


#Preview("Notification", as: .content, using: DeliveryAttributes.preview) {
   DeliveryLiveActivity()
} contentStates: {
    DeliveryAttributes.ContentState.smiley
}
