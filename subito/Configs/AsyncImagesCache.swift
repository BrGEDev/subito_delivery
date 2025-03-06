//
//  AsyncImagesCache.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 11/02/25.
//

import SwiftUI

@MainActor
struct AsyncImageCache<ImageView: View, PlaceholderView: View>: View {
    // Input dependencies
    var url: URL?
    var urlError: URL? = URL(string: "")
    @ViewBuilder var content: (Image) -> ImageView
    @ViewBuilder var placeholder: () -> PlaceholderView
    
    // Downloaded image
    @State var image: UIImage? = nil
    
    init(
        url: URL?,
        urlError: URL? = URL(string: ""),
        @ViewBuilder content: @escaping (Image) -> ImageView,
        @ViewBuilder placeholder: @escaping () -> PlaceholderView
    ) {
        self.url = url
        self.urlError = urlError
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        VStack {
            if let uiImage = image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .onAppear {
                        Task {
                            image = await downloadPhoto()
                        }
                    }
            }
        }
    }
    
    // Downloads if the image is not cached already
    // Otherwise returns from the cache
    private func downloadPhoto() async -> UIImage? {
        do {
            guard let url else { return nil }
            
            // Check if the image is cached already
            if let cachedResponse = URLCache.shared.cachedResponse(for: .init(url: url)) {
                return UIImage(data: cachedResponse.data)
            } else {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                // Save returned image data into the cache
                URLCache.shared.storeCachedResponse(.init(response: response, data: data), for: .init(url: url))
                
                if let image = UIImage(data: data) {
                    URLCache.shared.storeCachedResponse(.init(response: response, data: data), for: .init(url: url))
                    return image
                } else {
                    guard let urlError else { return nil }
                        let (data, _) = try await URLSession.shared.data(from: urlError)
                                          
                        guard let image = UIImage(data: data) else { return nil }
                        
                        return image
                }
            }
        } catch {
            print("Error downloading: \(error)")
            return nil
        }
    }
}
