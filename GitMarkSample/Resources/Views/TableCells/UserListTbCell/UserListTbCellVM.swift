//
//  UserListTbCellVM.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/04/30.
//

import UIKit
import RxSwift
import RxCocoa

class UserListTbCellVM: CellConfigType {
    
    var userItemModel: UserItemModel
    
    var disposeBag: DisposeBag = DisposeBag()
    var provider: ServiceProviderProtocol
    
    // MARK: Inputs
    var onAppear = PublishRelay<Bool>()
    var bookmarkAction = PublishRelay<Bool>()
    
    // MARK: Ouputs
    var image = PublishRelay<UIImage>()
    var infoModel = BehaviorRelay<UserInfoModel?>(value: nil)
    var hasMarked = BehaviorRelay<Bool>(value: false)
    
    init(cellHeight: CGFloat,
         provider: ServiceProviderProtocol,
         model: UserItemModel) {
        self.cellHeight = cellHeight
        self.provider = provider
        self.userItemModel = model
        
        onAppear
            .map { _ in model.login }
            .flatMap(provider.networkService.detail)
            .asObservable()
            .bind { [weak self] result in
                switch result {
                case .failure(let error):
                    print(String(describing: error))
                case .success(let userInfo):
                    self?.infoModel.accept(userInfo)
                }
            }
            .disposed(by: disposeBag)
        
        onAppear
            .compactMap { _ in model.avatarUrl }
            .flatMap(provider.imageService.downloadImage)
            .flatMap(provider.imageService.validateImage)
            .bind(to: image)
            .disposed(by: disposeBag)
        
        bookmarkAction
            .filter { !$0 }
            .filter { [weak self] _ in
                guard let `self` = self,
                      let _ = self.infoModel.value else {
                    return false
                }
                return true
            }
            .compactMap { _ in self }
            .map { `self` -> (UserItemModel, UserInfoModel) in
                (self.userItemModel, self.infoModel.value!)
            }
            .flatMap(provider.coreDataService.store)
            .asObservable()
            .catchAndReturn(.failure(CoreDataError.store))
            .bind(onNext: { [weak self] result in
                switch result {
                case .failure(let error):
                    print(String(describing: error))
                case .success:
                    self?.hasMarked.accept(true)
                }
            })
            .disposed(by: disposeBag)
        
        bookmarkAction
            .filter { $0 }
            .compactMap { _ in model.id }
            .flatMap(provider.coreDataService.match)
            .flatMap({ [weak self] result -> PrimitiveSequence<SingleTrait, Result<Bool, Error>> in
                guard let `self` = self else { return .never() }
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                    return .never()
                case .success(let item):
                    if let item = item {
                        return self.provider.coreDataService.remove(object: item)
                    }
                    return .never()
                }
            })
            .asObservable()
            .catchAndReturn(.failure(CoreDataError.remove))
            .bind(onNext: { [weak self] result in
                switch result {
                case .failure(let error):
                    print(String(describing: error))
                case .success:
                    self?.hasMarked.accept(true)
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    // MARK: CellConfigType
    
    var cellIdentifier: String = String(describing: UserListTbCell.self)
    var cellHeight: CGFloat
    
    func configure(cell: UITableViewCell,
                   with indexPath: IndexPath)
    -> UITableViewCell {
        if let cell = cell as? UserListTbCell {
            cell.viewModel = self
            return cell
        }
        return UITableViewCell()
    }
    
    func distinctIdentifier() -> String {
        """
        \(userItemModel.login)
        \(userItemModel.avatarUrl)
        \(hasMarked.value)
        """
    }
    
}
