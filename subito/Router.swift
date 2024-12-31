//
//  Router.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 09/09/24.
//

import SwiftUI

enum Route: Hashable{
    case Index
}

struct NavigationEnviromentKey: EnvironmentKey {
     static var defaultValue: (Route) -> Void = {_ in}
}

extension EnvironmentValues {
    var navigate: (Route) -> Void {
        get { self[NavigationEnviromentKey.self] }
        set { self[NavigationEnviromentKey.self] = newValue }
    }
}

struct Router: View {
    @State private var paths: [Route] = []
    var body: some View {
        NavigationStack(path: $paths) {
            ContentView()
                .environment(\.navigate) { route in
                    paths.append(route)
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .Index:
                        ContentView()
                    }
                }
        }
    }
}

@MainActor
struct AppSwitch: View {
    @EnvironmentObject var vm: UserStateModel
    
    var body: some View {
        ZStack{
            if vm.loggedIn {
                Router()
            } else {
                PrincipalView()
            }
        }
    }
}

