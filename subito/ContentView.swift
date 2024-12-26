//
//  ContentView.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 09/09/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @Environment(\.navigate) var navigate
    @Environment(\.modelContext) var modelContext
    
    @EnvironmentObject var vm: UserStateModel
    @ObservedObject var s: SocketService = SocketService()
    
    @StateObject var locationManager: LocationManager = .init()
    @StateObject var notifications: Notifications = .init()
    
    @State var location: CLLocation = .init()
    @State private var selection = 1
            
    var body: some View {
        if vm.isBusy == true {
            VStack{
                ProgressView().progressViewStyle(.circular)
                Text("Cerrando sesión")
            }
        } else {
            TabView(selection: $selection){
                Eats(socket: s)
                    .tabItem {
                        Label("Súbito Delivery", systemImage: "fork.knife")
                    }
                    .tag(1)
                
                Taxi(selection: $selection)
                    .tabItem {
                        Label("Súbito Drive", systemImage: "car.fill")
                    }
                    .tag(2)
            }
            .onAppear{
                locationManager.checkAuthorization()
                notifications.checkAuthorization()
            }
            .onChange(of: locationManager.coordinates){
                getDirections(location: locationManager.coordinates)
            }
        }
    }
}
