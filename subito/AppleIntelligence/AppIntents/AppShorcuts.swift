//
//  AppShorcuts.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 11/03/25.
//

import AppIntents

struct AppShorcuts: AppShortcutsProvider {

    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
//        AppShortcut(
//            intent: SearchInSubito(),
//            phrases: [
//                "Buscar en \(.applicationName)",
//                "Busca en \(.applicationName)",
//                "Busca un producto en \(.applicationName)",
//                "Busca un establecimiento en \(.applicationName)",
//            ],
//            shortTitle: "Buscar productos o establecimientos en Súbito",
//            systemImageName: "magnifyingglass"
//        )

        AppShortcut(
            intent: InCartSubito(),
            phrases: [
                "¿Qué tengo en mi carrito de \(.applicationName)",
                "Ve mi carrito de \(.applicationName)",
                "Ver mi carrito de \(.applicationName)",
                "Ver mi carrito en \(.applicationName)",
                "Consulta mi carrito de \(.applicationName)",
            ],
            shortTitle: "¿Qué tengo en mi carrito de Súbito?",
            systemImageName: "cart.fill"
        )
    }

}
