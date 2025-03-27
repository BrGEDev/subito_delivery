import MapKit
import SwiftData
import SwiftUI

extension Eats {
    func loadOrders() {
        if user?.id != nil {
            api.fetch(
                url: "orders_in_progress/\(user!.id)", method: "GET",
                token: user!.token, ofType: OrdersResponse.self
            ) { res, status in
                if status {
                    if res!.status == "success" {
                        withAnimation {
                            orders = res!.data!
                        }
                    }
                }
            }
        }
    }

}

struct Screen {
    static let height = UIScreen.main.bounds.height
    static let width = UIScreen.main.bounds.width
}
