//
//  IntelligentView.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 20/03/25.
//

import AppIntents
import SwiftData
import SwiftUI

@available(iOS 18.0, *)
struct IntelligentView: View {
    @Environment(\.modelContext) var context

    @StateObject var aiModel = EatsModel.shared
    var favIntelligence: FavData
    @State var openModal: Bool = false
    @State var alert: Bool = false

    @State var agregado: [Int] = []

    private let colors: [Color] = [
        Color(red: 0.29, green: 0.00, blue: 0.51),
        Color(red: 0.00, green: 0.00, blue: 0.55),
        Color(red: 0.10, green: 0.10, blue: 0.44),

        Color(red: 1.00, green: 0.41, blue: 0.71),
        Color(red: 0.85, green: 0.44, blue: 0.84),
        Color(red: 0.54, green: 0.17, blue: 0.89),

        Color(red: 0.29, green: 0.00, blue: 0.51),
        Color(red: 0.00, green: 0.00, blue: 0.55),
        Color(red: 0.10, green: 0.10, blue: 0.44),
    ]

    private let points: [SIMD2<Float>] = [
        SIMD2<Float>(0.0, 0.0), SIMD2<Float>(0.5, 0.0), SIMD2<Float>(1.0, 0.0),
        SIMD2<Float>(0.0, 0.5), SIMD2<Float>(0.5, 0.5), SIMD2<Float>(1.0, 0.5),
        SIMD2<Float>(0.0, 1.0), SIMD2<Float>(0.5, 1.0), SIMD2<Float>(1.0, 1.0),
    ]

    var body: some View {
        TimelineView(.animation) { timeline in
            ZStack {
                VStack(alignment: .leading, spacing: 20) {
                    Label {
                        Text("A estas horas sueles pedir en")
                            .font(.headline.bold())

                    } icon: {
                        Image(systemName: "motorcycle.fill")
                    }
                    .foregroundStyle(
                        MeshGradient(
                            width: 3,
                            height: 3,
                            locations: .points(points),
                            colors: .colors(animatedColors(for: timeline.date)),
                            background: .black,
                            smoothsColors: true
                        )
                    )

                    VStack {
                        AsyncImageCache(
                            url: URL(
                                string:
                                    "https://da-pw.mx/APPRISA/\(favIntelligence.establecimiento.logo)"
                            )
                        ) { image in
                            image
                                .resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .scaledToFill()
                        .frame(width: 75, height: 75)
                        .clipShape(Circle())
                        .clipped()

                        Text(favIntelligence.establecimiento.nombre)
                            .bold()

                        VStack {
                            Text("Ver mis favoritos")
                                .font(.caption)
                                .padding(10)
                        }
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(.capsule)
                    }
                    .frame(
                        maxWidth: .infinity, maxHeight: .infinity,
                        alignment: .center
                    )
                }
                .padding()
                .frame(
                    maxWidth: .infinity, maxHeight: .infinity,
                    alignment: .leading
                )
                .background(Material.ultraThick)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .clipped()
            }
            .background(
                MeshGradient(
                    width: 3,
                    height: 3,
                    locations: .points(points),
                    colors: .colors(animatedColors(for: timeline.date)),
                    background: .cyan,
                    smoothsColors: true
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .clipped()
            .padding()
            .shadow(color: Color(red: 1.00, green: 0.42, blue: 0.42), radius: 4)
            .onTapGesture {
                openModal = true
            }
            .sheet(isPresented: $openModal) {
                VStack {
                    ScrollView {
                        HStack(alignment: .center) {
                            Text(favIntelligence.establecimiento.nombre)
                                .font(.largeTitle.bold())

                            Spacer()

                            AsyncImageCache(
                                url: URL(
                                    string:
                                        "https://da-pw.mx/APPRISA/\(favIntelligence.establecimiento.logo)"
                                )
                            ) { image in
                                image
                                    .resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .clipped()

                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            GlassBackGround(
                                width: .infinity, color: .white
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 25))

                        Spacer(minLength: 20)

                        if agregado.count == favIntelligence.productos.count {
                            VStack {
                                Label(
                                    "Para editar los productos accede a tu carrito directamente.",
                                    systemImage: "cart.fill"
                                )
                                .bold()
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                GlassBackGround(
                                    width: .infinity, color: .white
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .animation(
                                .smooth(duration: 0.2),
                                value: agregado.count
                                    == favIntelligence.productos.count)

                            Spacer(minLength: 20)
                        }

                        VStack(alignment: .leading, spacing: 15) {
                            Text("Productos más pedidos")
                                .font(.title2.bold())

                            Divider()

                            SiriTipView(intent: AddFavouriteSubito()).clipShape(
                                Capsule()
                            ).clipped().lineLimit(1)

                            VStack(spacing: 10) {
                                ForEach(favIntelligence.productos, id: \.id) {
                                    producto in

                                    HStack {
                                        HStack {
                                            AsyncImageCache(
                                                url: URL(
                                                    string: producto.imagen
                                                )
                                            ) { image in
                                                image
                                                    .resizable()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(width: 60, height: 60)
                                            .scaledToFill()
                                            .clipShape(
                                                RoundedRectangle(
                                                    cornerRadius: 15)
                                            )
                                            .clipped()

                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Text(producto.nombre)
                                                        .font(.headline.bold())
                                                        .lineLimit(1)
                                                        .truncationMode(.tail)

                                                    Spacer()

                                                    Text(
                                                        "x\(producto.promedioCompra)"
                                                    )
                                                }
                                                Text(
                                                    "Has comprado este producto \(producto.vecesCompra) \(producto.vecesCompra == 1 ? "vez" : "veces")"
                                                )
                                                .font(.caption)
                                            }
                                        }

                                        Spacer()

                                        Button(action: {
                                            aiModel.addToCart(
                                                context: context,
                                                type: .one(product: producto)
                                            ) { result in
                                                if result {
                                                    agregado.append(producto.id)
                                                } else {
                                                    alert = true
                                                }
                                            }
                                        }) {
                                            if !agregado.contains(producto.id) {
                                                Text("Agregar")
                                                    .font(.caption)
                                            } else {
                                                Image(
                                                    systemName:
                                                        "checkmark.circle.fill"
                                                )
                                                .scaledToFit()
                                            }
                                        }
                                        .padding(10)
                                        .buttonStyle(.plain)
                                        .background(
                                            RoundedRectangle(
                                                cornerRadius: agregado.contains(
                                                    producto.id) ? 50 : 25
                                            )
                                            .fill(
                                                agregado.contains(producto.id)
                                                    ? .green : .blue
                                            )
                                            .animation(
                                                .linear(duration: 0.2),
                                                value: agregado.contains(
                                                    producto.id))
                                        )
                                        .disabled(
                                            agregado.contains(producto.id))
                                    }
                                    .padding(10)
                                    .background(
                                        GlassBackGround(
                                            width: .infinity,
                                            color: .black.opacity(0.4),
                                            radius: 10, border: false
                                        )
                                        .shadow(radius: 2)
                                    )
                                    .foregroundStyle(.white)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            GlassBackGround(
                                width: .infinity, color: .white
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 25))

                        Spacer(minLength: 15)

                        Text(
                            "Súbito aprende de las compras de tu día a día para ayudarte a agilizar tu próximo pedido."
                        )
                        .font(.caption)
                    }
                    .animation(
                        .smooth(duration: 0.2),
                        value: agregado.count == favIntelligence.productos.count
                    )
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Material.thin)
                    .ignoresSafeArea()
                    .alert(
                        "Error",
                        isPresented: $alert
                    ) {
                        Button(role: .destructive, action:{}) {
                            Text("Borrar carrito y agregar nuevos")
                        }
                    } message: {
                        Text("No se pudo agregar el producto porque ya cuenta con productos en su carrito, ¿Desea borrar el carrito y agregar nuevos productos?")
                    }
                    .safeAreaInset(edge: .bottom) {
                        Button(action: {
                            aiModel.addToCart(context: context, type: .all) {
                                result in
                                if result {
                                    getCart()
                                    openModal = false
                                } else {
                                    alert = true
                                }
                            }
                        }) {
                            if agregado.count == favIntelligence.productos.count
                            {
                                Label(
                                    "Todo está en tu carrito",
                                    systemImage: "checkmark.circle.fill"
                                )
                                .frame(maxWidth: .infinity)
                                .padding(5)
                            } else {
                                Text("Agregar todo a mi carrito")
                                    .frame(maxWidth: .infinity)
                                    .padding(5)
                            }
                        }
                        .foregroundStyle(.white)
                        .padding(10)
                        .buttonStyle(.plain)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(
                                    agregado.count
                                        == favIntelligence.productos.count
                                        ? Color.green
                                        : Color(
                                            red: 0.85, green: 0.44, blue: 0.84)
                                )
                                .animation(
                                    .linear(duration: 0.2),
                                    value: agregado.count
                                        == favIntelligence.productos.count)
                        )
                        .padding(.horizontal)
                        .disabled(
                            agregado.count == favIntelligence.productos.count)
                    }
                    .onAppear {
                        getCart()
                    }
                }
                .presentationCornerRadius(35)
                .presentationBackground(
                    MeshGradient(
                        width: 3,
                        height: 3,
                        locations: .points(points),
                        colors: .colors(animatedColors(for: timeline.date)),
                        background: .cyan,
                        smoothsColors: true
                    )
                )
            }
        }
    }

    private func animatedColors(for date: Date) -> [Color] {
        let phase = CGFloat(date.timeIntervalSince1970)

        return colors.enumerated().map { index, color in
            let hueShift = cos(phase + Double(index) * 0.3) * 0.1
            return shiftHue(of: color, by: hueShift)
        }
    }

    private func shiftHue(of color: Color, by amount: Double) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        UIColor(color).getHue(
            &hue, saturation: &saturation, brightness: &brightness,
            alpha: &alpha)

        hue += CGFloat(amount)
        hue = hue.truncatingRemainder(dividingBy: 1.0)

        if hue < 0 {
            hue += 1
        }

        return Color(
            hue: Double(hue), saturation: Double(saturation),
            brightness: Double(brightness), opacity: Double(alpha))
    }

    private func getCart() {
        agregado = []

        let id = Int(favIntelligence.establecimiento.id)!
        var query2: FetchDescriptor<CartSD> {
            let descriptor = FetchDescriptor<CartSD>(
                predicate: #Predicate {
                    $0.id == id
                })
            return descriptor
        }

        let inCart = try! context.fetch(query2).first
        if inCart != nil {
            inCart!.products.forEach { product in
                agregado.append(product.id)
            }
        }
    }
}
