//
//  WebView.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 17/12/24.
//

import SwiftUI
import WebKit
import SwiftData

struct WebView: UIViewRepresentable {
    let url: URL
    
    @Binding var isLoading: Bool
    @Binding var error: Error?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        let mkwebview = WKWebView(frame: CGRect.null, configuration: configuration)
        let request = URLRequest(url: url)
        mkwebview.load(request)
        
        return mkwebview
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        init(_ parent: WebView) {
            self.parent = parent
        }
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("loading error: \(error)")
            parent.isLoading = false
            parent.error = error
        }
    }
}

struct LoadWebView: View {
    @Environment(\.modelContext)var modelContext
    @Environment(\.dismiss)var dismiss
    @Environment(\.colorScheme)var colorScheme
    
    @State private var isLoading = true
    @State private var error: Error? = nil

    let url: URL?
    @Query var userData: [UserSD]
    private var user: UserSD? { userData.first }
    
    var body: some View {
        ZStack {
            if let error = error {
                Text(error.localizedDescription)
                    .foregroundColor(.pink)
            } else if let url = url {
                VStack(alignment: .leading){
                    HStack{
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }){
                            Image(systemName: "xmark")
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(colorScheme == .dark ? .black : .white)
                        .buttonBorderShape(.circle)
                        .shadow(radius: 17)
                    }
                    
                    Spacer()
                }
                .padding()
                .zIndex(20)
                
                WebView(url: url, isLoading: $isLoading, error: $error)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("Ocurrió un error de conexión, intente más tarde.")
            }
        }
    }
}
