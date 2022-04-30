//
//  NetworkService.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/04/29.
//

import UIKit
import RxSwift
import Alamofire

protocol NetworkServiceProtocol {
    
    func search(with query: String, for page: Int)
    -> PrimitiveSequence<SingleTrait, Result<SearchResponseModel, Error>>
    
}

class NetworkService: NetworkServiceProtocol {
    
    private let manager: Session
    private let decoder: JSONDecoder
    
    init(manager: Session,
         decoder: JSONDecoder) {
        self.manager = manager
        self.decoder = decoder
    }
    
    func search(with query: String, for page: Int)
    -> PrimitiveSequence<SingleTrait, Result<SearchResponseModel, Error>> {
        return Single.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            let url = APIRouter.searchUsers(query: query,
                                            sort: .bestMatch,
                                            order: .asc,
                                            page: page,
                                            perPage: 10)
            self.manager.request(url)
                .responseData { response in
                    if let error = response.error {
                        single(.failure(error))
                    } else if let data = response.value {
                        do {
                            let decoded = try self.decoder
                                .decode(SearchResponseModel.self,
                                        from: data)
                            single(.success(.success(decoded)))
                        } catch let error {
                            single(.failure(error))
                        }
                    }
                }
            return Disposables.create()
        }
    }
    
}
