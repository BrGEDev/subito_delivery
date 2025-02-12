import Foundation
import SwiftUI
import Combine

final class SearchViewModel: ObservableObject {
    private var disposeBag = Set<AnyCancellable>()
    private var api: ApiCaller = ApiCaller()
    @Published var searchText: String = ""
    @Published var results: SearchData? = nil
    
    
    init(){
        searchSubito()
    }
    
    private func searchSubito() {
        $searchText.debounce(for: 0.500, scheduler: RunLoop.main)
            .sink {
                let data = [
                    "search" : $0
                ]
                
                self.api.fetch(url: "search", method: "POST", body: data, ofType: SearchResponse.self) { res in
                    self.results = nil
                    
                    if res.status == "success" {
                        self.results = res.data!
                    }
                }
            }
            .store(in: &disposeBag)
    }
}
