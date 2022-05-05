//
//  BookmarksViewModel.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/04/29.
//

import UIKit
import RxSwift
import RxCocoa

class BookmarksViewModel {
    
    let title: String
    let placeHolder: String
    
    private var query: String?
    private var currPage = 1
    private var isLoadingNextPage: Bool = false
    private var currConfigsDict: [String: [CellConfigType]] = [:]
    
    private var provider: ServiceProviderProtocol
    private var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: Inputs
    var onAppear = PublishRelay<Bool>()
    var search = BehaviorRelay<String?>(value: nil)
    var nextPage = PublishRelay<Bool>()
    var cancel = PublishRelay<Bool>()
    
    // MARK: Outputs
    var cellConfigs = BehaviorRelay<[BookmarkSection]>(value: [])
    
    init(title: String,
         placeHolder: String,
         provider: ServiceProviderProtocol) {
        self.title = title
        self.placeHolder = placeHolder
        self.provider = provider
        
        onAppear
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.isLoadingNextPage = true
                self.currConfigsDict = [:]
                self.currPage = 1
            })
            .map { _ in self.query }
            .flatMap { [weak self] query -> PrimitiveSequence<SingleTrait, Result<[UserItem], Error>> in
                guard let `self` = self else { return .never() }
                if let query = query {
                    return provider.coreDataService.search(with: query,
                                                           for: self.currPage)
                }
                return provider.coreDataService.fetch(page: self.currPage)
            }
            .flatMap(convertToCellConfigs)
            .flatMap(bookmarkSections)
            .filter { $0.count > 0 }
            .catchAndReturn([])
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.currPage += 1
                self.isLoadingNextPage = false
            })
            .bind(to: cellConfigs)
            .disposed(by: disposeBag)
        
        search
            .compactMap { $0 }
            .filter { $0.count > 0 }
            .filter { [weak self] _ in !(self?.isLoadingNextPage ?? false) }
            .do(onNext: { [weak self] query in
                guard let `self` = self else { return }
                self.isLoadingNextPage = true
                self.query = query
                self.currConfigsDict = [:]
            })
            .flatMap {
                provider.coreDataService.search(with: $0,
                                                for: 1)
            }
            .flatMap(convertToCellConfigs)
            .flatMap(bookmarkSections)
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
            .map { _ in self.query }
            .do(onNext: { [weak self] _ in
                self?.isLoadingNextPage = true
            })
            .flatMap { [weak self] query -> PrimitiveSequence<SingleTrait, Result<[UserItem], Error>> in
                guard let `self` = self else { return .never() }
                if let query = query {
                    return provider.coreDataService.search(with: query,
                                                           for: self.currPage+1)
                }
                return provider.coreDataService.fetch(page: self.currPage+1)
            }
            .flatMap(convertToCellConfigs)
            .flatMap(bookmarkSections)
            .do(onNext: { [weak self] _ in
                self?.isLoadingNextPage = false
            })
            .filter { $0.count > 0 }
            .catchAndReturn([])
            .do(onNext: { [weak self] _ in
                self?.currPage += 1
            })
            .bind(to: cellConfigs)
            .disposed(by: disposeBag)
        
        cancel
            .bind(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.isLoadingNextPage = true
                self.query = nil
                self.currPage = 1
                self.currConfigsDict = [:]
            })
            .disposed(by: disposeBag)
                
    }
    
    // MARK: Function components
    
    private func bookmarkSections(with configsDict: [String: [CellConfigType]])
    -> Single<[BookmarkSection]> {
        return Single.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            self.currConfigsDict = configsDict
            
            var sections: [BookmarkSection] = []
            
            let sortedConfigs = configsDict.sorted { lhs, rhs in
                lhs.key < rhs.key
            }
            
            sortedConfigs.forEach { key, val in
                sections.append(
                    BookmarkSection(header: key,
                                    items: val)
                )
            }
            
            single(.success(sections))
            
            return Disposables.create()
        }
    }
    
    private func convertToCellConfigs(with result: Result<[UserItem], Error>)
    -> Single<[String: [CellConfigType]]> {
        return Single.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                observer(.failure(error))
            case .success(let items):
                if items.count <= 0 {
                    observer(.success([:]))
                }
                var configsDict: [String: [CellConfigType]] = self.currConfigsDict
                
                items.forEach { [weak self] item in
                    guard let `self` = self else { return }
                    
                    let model = UserItemModel(login: item.login!,
                                              id: Int(item.id),
                                              avatarUrl: item.avatarUrl!)
                    
                    let config = UserListTbCellVM(cellHeight: 110,
                                                  provider: self.provider,
                                                  model: model)
                    
                    let headerTxt = (item.name ?? item.login!).firstLetter() ?? ""
                    if let _ = configsDict[headerTxt] {
                        configsDict[headerTxt]?.append(config)
                    } else {
                        configsDict[headerTxt] = [config]
                    }
                }
                
                observer(.success(configsDict))
            }
            return Disposables.create()
        }
    }
    
}

