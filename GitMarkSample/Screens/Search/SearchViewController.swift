//
//  SearchViewController.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/04/29.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxViewController

class SearchViewController: UIViewController {
    
    var sc: UISearchController!
    var tv: UITableView!
    
    var disposeBag: DisposeBag = DisposeBag()
    var viewModel: SearchViewModel?
    
    override func loadView() {
        super.loadView()
        guard let viewModel = viewModel else { return }
        setupView(with: viewModel)
        bind(with: viewModel)
    }
    
}

extension SearchViewController {
    
    private func setupView(with viewModel: SearchViewModel) {
        guard let nc = navigationController else { return }
        nc.navigationBar.prefersLargeTitles = true
        navigationItem.title = viewModel.title
        view.backgroundColor = .white
        
        sc = {
            let sc = UISearchController(searchResultsController: nil)
            sc.obscuresBackgroundDuringPresentation = false
            sc.searchBar.placeholder = viewModel.placeHolder
            sc.searchBar.autocapitalizationType = .none
            return sc
        }()
        navigationItem.searchController = sc
        
        tv = {
            let tv = UITableView()
            return tv
        }()
        tv.registerCells([
            UserListTbCell.self,
        ])
        tv.rx.setDelegate(self).disposed(by: disposeBag)
            
        view.addSubview(tv)
        
        tv.snp.makeConstraints {
            $0.top.bottom.equalTo(view)
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bind(with viewModel: SearchViewModel) {
        
        // MARK: Inputs
        viewModel
            .cellConfigs
            .bind(to: tv.rx.items) { tv, idx, item -> UITableViewCell in
                let cell = tv
                    .dequeueReusableCell(withIdentifier: item.cellIdentifier,
                                         for: IndexPath(row: idx,
                                                        section: 0))
                return item.configure(cell: cell,
                                      with: IndexPath(row: idx,
                                                      section: 0))
            }
            .disposed(by: disposeBag)
        
        // MARK: Outputs
        rx.viewDidLoad
            .map { true }
            .bind(to: viewModel.cancel)
            .disposed(by: disposeBag)
        
        sc.searchBar.rx
            .textDidEndEditing
            .compactMap { $0 }
            .throttle(.seconds(1),
                      scheduler: MainScheduler.instance)
            .map { [weak self] _ -> String? in
                self?.sc.searchBar.text
            }
            .do(onNext: { [weak self] _ in
                if self?.tv.visibleCells.count ?? 0 > 0 {
                    self?.tv.scrollToRow(at: IndexPath(row: 0, section: 0),
                                         at: .top,
                                         animated: false)
                }
            })
            .compactMap { $0 }
            .bind(to: viewModel.search)
            .disposed(by: disposeBag)
        
        sc.searchBar.rx
            .cancelButtonClicked
            .map { true }
            .bind(to: viewModel.cancel)
            .disposed(by: disposeBag)
        
        tv.rx.contentOffset
            .filter { [weak self] offset in
                guard let `self` = self else { return false }
                guard self.tv.frame.height > 0 else { return false }
                return offset.y + self.tv.frame.height >= self.tv.contentSize.height - 200
            }
            .map { _ in true }
            .bind(to: viewModel.nextPage)
            .disposed(by: disposeBag)
        
        tv.rx.itemSelected
            .bind { [weak self] indexPath in
                self?.tv.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)
        
    }
    
}

extension SearchViewController: UITableViewDelegate {
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel?.cellConfigs.value[indexPath.row].cellHeight ?? 0
    }
    
}
