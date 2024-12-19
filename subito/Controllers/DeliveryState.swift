//
//  DeliveryState.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 25/11/24.
//

import Foundation
import ActivityKit

enum DeliveryState: String, Codable {
    case pending = "Recolectando"
    case inProgress = "En reparto"
    case completed = "Completado"
    case cancelled = "Cancelado"
}

final class DeliveryActivity {
    static func startActivity(deliveryStatus: DeliveryState, establishment: String, estimaed: String, time: String) throws -> String {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return ""
        }
        
        let initialState = DeliveryAttributes.ContentState(DeliveryState: deliveryStatus, establishment: establishment, estimated: estimaed, time: time)
        
        let futureDate: Date = Date.now + 3600
        
        let activity = ActivityContent(state: initialState, staleDate: futureDate)
        
        let attributes = DeliveryAttributes()
        
        do {
            let activity = try Activity.request(attributes: attributes, content: activity, pushType: nil)
            
            return activity.id
        } catch {
            throw error
        }
            
    }
    
    static func updateActivity(activityIdentifier: String, newStatus: DeliveryState, establishment: String, estimated: String, time: String) async {
        let updatedState = DeliveryAttributes.ContentState(DeliveryState: newStatus, establishment: establishment, estimated: estimated, time: time)
        
        let activity = Activity<DeliveryAttributes>.activities.first(where: { $0.id == activityIdentifier })
        let activityContent = ActivityContent(state: updatedState, staleDate: .now + 3600)
        
        await activity?.update(activityContent)
    }
    
    static func endActivity(withActivityIdentifier activityIdentifier: String) async {
        let value = Activity<DeliveryAttributes>.activities.first(where: { $0.id == activityIdentifier })
        await value?.end(nil)
    }
}

struct DeliveryAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var DeliveryState: DeliveryState
        var establishment: String
        var estimated: String
        var time: String
    }
}
