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
    
    var query: String?
    var currPage = 0
    var isLoadingNextPage: Bool = false
    var isCanceled: Bool = false
    
    var currConfigsDict: [String: [CellConfigType]] = [:]
    
    var provider: ServiceProviderProtocol
    var disposeBag: DisposeBag = DisposeBag()
    
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
            })
            .flatMap { _ in
                provider.coreDataService.fetch(page: 1)
            }
            .flatMap(convertToCellConfigs)
            .flatMap(bookmarkSections)
            .filter { $0.count > 0 }
            .catchAndReturn([])
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.currPage = 1
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
                self.isCanceled = false
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
            .filter { [weak self] _ in !(self?.isCanceled ?? false) }
            .compactMap { _ in self.query }
            .do(onNext: { [weak self] _ in
                self?.isLoadingNextPage = true
            })
            .flatMap { [weak self] query -> PrimitiveSequence<SingleTrait, Result<[UserItem], Error>> in
                guard let `self` = self else { return .never() }
                return provider.coreDataService.search(with: query,
                                                       for: self.currPage+1)
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
                
            cancel
                .bind(onNext: { [weak self] _ in
                    guard let `self` = self else { return }
                    self.isCanceled = true
                    self.cellConfigs.accept([])
                })
                .disposed(by: disposeBag)

    }
    
    // MARK: Function components
    
    private func appendSections(with configsDict: [String: [CellConfigType]])
    -> Single<[BookmarkSection]> {
        return Single.create { single in
            
            var sections: [BookmarkSection] = self.cellConfigs.value
            
            let sortedConfigs = configsDict.sorted { lhs, rhs in
                lhs.key > rhs.key
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
                var configsDict: [String: [CellConfigType]] = self.currConfigsDict
                
                items.forEach { [weak self] item in
                    guard let `self` = self else { return }
                    
                    let model = UserItemModel(login: item.login!,
                                              id: Int(item.id),
                                              avatarUrl: item.avatarUrl!)
                    
                    let config = UserListTbCellVM(cellHeight: 110,
                                                  provider: self.provider,
                                                  model: model)
                    
                    let headerTxt = self.firstLetter(text: item.name ?? item.login!) ?? ""
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
    
    private func firstLetter(text: String) -> String? {
        // 영문
        if let asciiVal = text.uppercased().first?.asciiValue,
           asciiVal >= 65,
           asciiVal <= 95 {
            return String(UnicodeScalar(UInt8(asciiVal)))
        }
        
        // 한글
        guard let first = text.first else { return nil }
        let unicode = UnicodeScalar(String(first))?.value
        guard let unicodeChar = unicode else { return nil }
        // 초성
        let x = (unicodeChar - 0xac00) / 28 / 21
        // 중성
        // let y = ((unicodeChar - 0xac00) / 28) % 21
        // let j = UnicodeScalar(0x1161 + y)
        // 종성
        // let z = (unicodeChar - 0xac00) % 28
        // let k = UnicodeScalar(0x11a6 + 1 + z)
        
        if let i = UnicodeScalar(0x1100 + x) {
            return String(i)
        }
        return nil
    }
    
}

