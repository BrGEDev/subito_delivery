import Foundation
import SwiftUI
import Combine

final class SearchViewModel: ObservableObject {
    private var disposeBag = Set<AnyCancellable>()
    private var api: ApiCaller = ApiCaller()
    @Published var searchText: String = ""
    @Published var results: SearchData? = nil
    @Published var loading: Bool = false
    
    init(){
        searchSubito()
    }
    
    private func searchSubito() {
        $searchText.debounce(for: 0.500, scheduler: RunLoop.main)
            .sink {
                if !$0.isEmpty {
                    let data = [
                        "search" : $0
                    ]
                    
                    self.loading = true
                    
                    self.api.fetch(url: "search", method: "POST", body: data, ofType: SearchResponse.self) { res, status in
                        self.results = nil
                        self.loading = false
                        if status {
                            if res!.status == "success" {
                                self.results = res!.data!
                            }
                        }
                    }
                }
            }
            .store(in: &disposeBag)
    }
}
