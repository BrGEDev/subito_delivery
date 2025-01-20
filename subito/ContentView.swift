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
            Eats()
            .onAppear{
                locationManager.checkAuthorization()
                
                Task {
                    await notifications.checkAuthorization()
                }
            }
            .onChange(of: locationManager.coordinates){
                getDirections(location: locationManager.coordinates)
            }
        }
    }
}

extension View {
    func navigationBarTitleColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
        UINavigationBarAppearance().configureWithOpaqueBackground()
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor]
        return self
    }
}
