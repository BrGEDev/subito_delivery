import SwiftUI
import SwiftData

final class PendingOrderModel: ObservableObject {
    @State var currentDeliveryState: DeliveryState = .pending
    @State var activityIdentifier: String = ""
    
    var socket = SocketService.socketClient
    @Published var pendingModal: Bool = false
    @Published var title: String = "Esperando confirmación del establecimiento"
    @Published var loading: Bool = true

    static let shared = PendingOrderModel()
    
    func listeners(order: TrackingSD, router: NavigationManager, context: ModelContext) {
        title = "Esperando confirmación del establecimiento"
        loading = true
        
        socket.socket.on("orderDelivery") { data, ack in
            
            let dataArray = data as NSArray
            let dataString = dataArray[0] as! NSDictionary
            
            print(dataString)
            
            if dataString["response"] != nil {
                let id_order = dataString["orderId"] as? NSNumber ?? 0
                let orders = id_order
                
                print("Socket: \(orders.intValue), Orden: \(order.order), ¿es igual? \(orders.intValue == order.order)")
                if orders.intValue == order.order {
                    if dataString["response"] as! NSNumber == 1
                    {
                        self.pendingModal = false
                        try! context.delete(model: CartSD.self)
                        try! context.save()
                        
                        do {
                            self.currentDeliveryState = .preparation
                            self.activityIdentifier =
                            try DeliveryActivity.startActivity(
                                deliveryStatus: .preparation,
                                establishment: order.establishment,
                                estimaed: order.estimatedTime
                            )
                        } catch {
                            print("Murió el activity")
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            router.navigateTo(.Order(id: String(order.order)))
                        }
                    } else {
                        let message = dataString["message"] as? NSString
                        withAnimation {
                            self.loading = false
                            self.title = message?.description ?? "Ocurrió un error con su tarjeta, verifique la información o comuníquese con su banco emisor."
                        }
                    }
                }
            }
        }
        
        
    }
    
    
    func updateState() {
        currentDeliveryState = .inProgress

        Task {
            await DeliveryActivity.updateActivity(
                activityIdentifier: activityIdentifier,
                newStatus: currentDeliveryState,
                establishment: "Starbucks Coffee", estimated: "11:30 am",
                time: "8 min")
        }
    }

    // Remueve el status del widget

    func removeState() {
        Task {
            await DeliveryActivity.endActivity(
                withActivityIdentifier: activityIdentifier)
        }
    }
}
