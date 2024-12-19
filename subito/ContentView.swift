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
    @EnvironmentObject var vm: UserStateModel
    @StateObject var locationManager: LocationManager = .init()
    @Environment(\.modelContext) var modelContext
    
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
                Eats()
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
            }
            .onChange(of: locationManager.coordinates){
                getDirections(location: locationManager.coordinates)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [DirectionSD.self, UserSD.self])
        .environmentObject(UserStateModel())
}
