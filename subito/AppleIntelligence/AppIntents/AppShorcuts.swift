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
                "¿Qué tengo en mi carrito de \(.applicationName)?",
                "Ve mi carrito de \(.applicationName)",
                "Ver mi carrito de \(.applicationName)",
                "Ver mi carrito en \(.applicationName)",
                "Consulta mi carrito de \(.applicationName)",
                "Mi carrito en \(.applicationName)",
                "Carrito en \(.applicationName)",
                "Carrito de \(.applicationName)",
            ],
            shortTitle: "¿Qué tengo en mi carrito de Súbito?",
            systemImageName: "cart.fill"
        )

        AppShortcut(
            intent: DeleteCartSubito(),
            phrases: [
                "Elimina mi carrito de \(.applicationName)",
                "Vacia mi carrito de \(.applicationName)",
                "Elimina todo en mi carrito de \(.applicationName)",
                "Vacia todo en mi carrito de \(.applicationName)",
                "Limpiar mi carrito de \(.applicationName)",
                "Limpiar todo en mi carrito de \(.applicationName)",
                "Borrar mi carrito de \(.applicationName)",
                "Borrar todo en mi carrito de \(.applicationName)",
                "Quita todo en mi carrito de \(.applicationName)",
                "Quita todo de mi carrito de \(.applicationName)",
            ], shortTitle: "Elimina mi carrito de Súbito",
            systemImageName: "trash.fill"
        )
    }

}
