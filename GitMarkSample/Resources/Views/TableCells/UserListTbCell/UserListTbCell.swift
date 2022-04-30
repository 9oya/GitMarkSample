//
//  UserListTbCell.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/04/29.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class UserListTbCell: UITableViewCell {
    
    var imgView: UIImageView!
    var nameLabel: UILabel!
    var button: UIButton!
    
    var disposeBag: DisposeBag = DisposeBag()
    var viewModel: UserListTbCellVM? {
        didSet {
            if let viewModel = viewModel {
                bind(with: viewModel)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        imgView.image = nil
        button.setImage(nil, for: .normal)
        
        disposeBag = DisposeBag()
        viewModel = nil
        
    }
    
    private func setupViews() {
        imgView = {
            let imgView = UIImageView()
            imgView.contentMode = .scaleAspectFit
            return imgView
        }()
        nameLabel = {
            let label = UILabel()
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 4
            return label
        }()
        button = {
            let btn = UIButton()
            return btn
        }()
        
        contentView.addSubview(imgView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(button)
        
        imgView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().inset(10)
            $0.width.equalTo(90)
            $0.height.equalTo(contentView.snp.height)
        }
        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(imgView.snp.right).offset(15)
            $0.right.equalTo(button.snp.left).offset(-15)
        }
        button.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(20)
            $0.width.height.equalTo(50)
        }
        
    }
    
    private func bind(with viewModel: UserListTbCellVM) {
        
        // MARK: Inputs
        viewModel
            .image
            .observe(on: MainScheduler.instance)
            .bind(to: imgView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel
            .infoModel
            .filter { $0 != nil }
            .map { [weak self] model in
                if let name = model!.name {
                    return name
                } else {
                    return self?.viewModel?.userItemModel.login ?? ""
                }
            }
            .observe(on: MainScheduler.instance)
            .bind(to: nameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel
            .hasMarked
            .observe(on: MainScheduler.instance)
            .bind { [weak self] hasMarked in
                guard let `self` = self else  { return }
                let config = UIImage
                    .SymbolConfiguration(pointSize: 23.0,
                                         weight: .regular,
                                         scale: .large)
                var image = UIImage(systemName: "bookmark",
                                    withConfiguration: config)
                if hasMarked {
                    image = UIImage(systemName: "bookmark.fill",
                                    withConfiguration: config)
                }
                self.button.isSelected = hasMarked
                self.button.setImage(image, for: .normal)
            }
            .disposed(by: disposeBag)
        
        
        // MARK: Outputs
        Observable.just(true)
            .asObservable()
            .bind(to: viewModel.onAppear)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .do(onNext: { _ in
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            })
            .map { [weak self] _ in self?.button.isSelected ?? false }
            .bind(to: viewModel.bookmarkAction)
            .disposed(by: disposeBag)
        
    }
    
}
