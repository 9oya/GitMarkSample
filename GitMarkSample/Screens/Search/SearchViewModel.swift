//
//  SearchViewModel.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/04/29.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewModel {
    
    let title: String
    let placeHolder: String
    
    var query: String?
    var currPage = 0
    var isLoadingNextPage: Bool = false
    var isCanceled: Bool = false
    
    var provider: ServiceProviderProtocol
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: Inputs
    var search = BehaviorRelay<String?>(value: nil)
    var nextPage = PublishRelay<Bool>()
    var cancel = PublishRelay<Bool>()
    
    // MARK: Outputs
    var cellConfigs = BehaviorRelay<[CellConfigType]>(value: [])
    
    init(title: String,
         placeHolder: String,
         provider: ServiceProviderProtocol) {
        self.title = title
        self.placeHolder = placeHolder
        self.provider = provider
        
        search
            .compactMap { $0 }
            .filter { $0.count > 0 }
            .filter { [weak self] _ in !(self?.isLoadingNextPage ?? false) }
            .do(onNext: { [weak self] query in
                guard let `self` = self else { return }
                self.isLoadingNextPage = true
                self.isCanceled = false
                self.query = query
            })
            .flatMap {
                provider.networkService.search(with: $0,
                                               for: 1)
            }
            .flatMap(convertToCellConfigs)
            .filter { $0.count > 0 }
            .catchAndReturn([])
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.currPage = 1
                self.isLoadingNextPage = false
            })
            .bind(to: cellConfigs)
            .disposed(by: disposeBag)
        
        nextPage
            .filter { [weak self] _ in !(self?.isLoadingNextPage ?? false) }
            .filter { [weak self] _ in !(self?.isCanceled ?? false) }
            .compactMap { _ in self.query }
            .do(onNext: { [weak self] _ in
                self?.isLoadingNextPage = true
            })
            .flatMap { [weak self] query -> PrimitiveSequence<SingleTrait, Result<SearchResponseModel, Error>> in
                guard let `self` = self else { return .never() }
                return provider.networkService
                    .search(with: query,
                            for: self.currPage+1)
            }
            .flatMap(convertToCellConfigs)
            .catchAndReturn([])
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.currPage += 1
                self.isLoadingNextPage = false
            })
            .bind(onNext: { [weak self] configs in
                guard let `self` = self else { return }
                self.cellConfigs.accept(self.cellConfigs.value+configs)
            })
            .disposed(by: disposeBag)
                
            cancel
                .bind(onNext: { [weak self] _ in
                    guard let `self` = self else { return }
                    self.isCanceled = true
                    self.cellConfigs.accept([])
                })
                .disposed(by: disposeBag)

    }
    
    // MARK: Function components
    
    private func convertToCellConfigs(with result: Result<SearchResponseModel, Error>)
    -> Single<[CellConfigType]> {
        return Single.create { observer in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                observer(.failure(error))
            case .success(let model):
                var configs: [CellConfigType] = []
                
                model.items.forEach {
                    configs.append(
                        UserListTbCellVM(cellHeight: 110,
                                         provider: self.provider,
                                         model: $0)
                    )
                }
                
                observer(.success(configs))
            }
            return Disposables.create()
        }
    }
    
}
