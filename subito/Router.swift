//
//  Router.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 09/09/24.
//

import SwiftUI

enum Route: Hashable{
    case Index
    case Establishment(categoryTitle: String, id: Int)
    case Order(id: String)
}

enum RouteSignOut: Hashable{
    case Index
    case Login
    case Establishment(categoryTitle: String, id: Int)
}


class NavigationManager: ObservableObject {
    @Published var navigationPath = NavigationPath()
    static var shared = NavigationManager()
    
    func navigateTo(_ route: Route) {
        navigationPath.append(route)
    }
    
    func navigateSignOutTo(_ route: RouteSignOut) {
        navigationPath.append(route)
    }
}

struct Router: View {
    @ObservedObject var paths = NavigationManager.shared
    var body: some View {
        NavigationStack(path: $paths.navigationPath) {
            ContentView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .Index:
                        ContentView()
                    case .Establishment(let type, let id):
                        CategoryView(categoryTitle: type, id_category: id)
                    case .Order(let id):
                        OrderDetail(order: id)
                    }
                }
        }
    }
}

struct RouterSignOut: View {
    @ObservedObject var paths = NavigationManager.shared
    var body: some View {
        NavigationStack(path: $paths.navigationPath) {
            Index()
                .navigationDestination(for: RouteSignOut.self) { route in
                    switch route {
                    case .Index:
                        Index()
                    case .Login:
                        PrincipalView()
                    case .Establishment(let type, let id):
                        CategoryView(categoryTitle: type, id_category: id)
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
                RouterSignOut()
            }
        }
    }
}

