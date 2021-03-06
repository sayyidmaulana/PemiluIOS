//
//  PilpresViewController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 18/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PilpresViewController: UITableViewController {
    
    private let disposeBag = DisposeBag()
    private var headerView: BannerHeaderView!
    private var emptyView = EmptyView()
    private var viewModel: PilpresViewModel!
    
    var rControl : UIRefreshControl?
    
    convenience init(viewModel: PilpresViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerReusableCell(LinimasaCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        
        viewModel.output.showHeader
            .drive(onNext: { [unowned self](isHeaderShown) in
                if isHeaderShown {
                    self.headerView = BannerHeaderView()
                    self.tableView.tableHeaderView = self.headerView
                    
                    self.viewModel.output.bannerInfo
                        .drive(onNext: { (banner) in
                            self.headerView.config(banner: banner, viewModel: self.viewModel.headerViewModel)
                        })
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        self.refreshControl?.rx.controlEvent(.valueChanged)
            .map({ (_) -> String in
                return ""
            })
            .bind(to: viewModel.input.refreshTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.feedsCells
            .do(onNext: { [weak self] (items) in
                guard let `self` = self else { return }
                self.tableView.backgroundView = nil
                if items.count == 0 {
                    self.emptyView.frame = self.tableView.bounds
                    self.tableView.backgroundView = self.emptyView
                } else {
                    self.tableView.backgroundView = nil
                }
                self.refreshControl?.endRefreshing()
            })
            .drive(tableView.rx.items) { tableView, row, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) else {
                    return UITableViewCell()
                }
                cell.tag = row
                item.configure(cell: cell)
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .distinctUntilChanged()
            .flatMapLatest { (offset) -> Observable<Void> in
                if offset.y > self.tableView.contentSize.height -
                    (self.tableView.frame.height * 2) {
                    return Observable.just(())
                } else {
                    return Observable.empty()
                }
            }
            .bind(to: viewModel.input.nextTrigger)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(to: viewModel.input.itemSelectTrigger)
            .disposed(by: disposeBag)
        
        
        viewModel.output.moreSelected
            .asObservable()
            .flatMapLatest({ [weak self] (feeds) -> Observable<PilpresType> in
                return Observable.create({ (observer) -> Disposable in
                    
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//                    let salin = UIAlertAction(title: "Salin Tautan", style: .default, handler: { (_) in
//                        observer.onNext(PilpresType.salin(data: feeds))
//                        observer.on(.completed)
//                    })
//                    let bagikan = UIAlertAction(title: "Bagikan", style: .default, handler: { (_) in
//                        observer.onNext(PilpresType.bagikan(data: feeds))
//                        observer.on(.completed)
//                    })
                    let twitter = UIAlertAction(title: "Buka di Aplikasi Twitter", style: .default, handler: { (_) in
                        observer.onNext(PilpresType.twitter(data: feeds))
                        observer.on(.completed)
                    })
                    let cancel = UIAlertAction(title: "Batal", style: .cancel, handler: nil)
//                    alert.addAction(salin)
//                    alert.addAction(bagikan)
                    alert.addAction(twitter)
                    alert.addAction(cancel)
                    DispatchQueue.main.async {
                        self?.navigationController?.present(alert, animated: true, completion: nil)
                    }
                    return Disposables.create()
                })
            })
            .bind(to: viewModel.input.moreMenuTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.moreMenuSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.infoSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.filter
            .drive(onNext: { [weak self] (_) in
                // set to top of table view after set filter
                self?.refreshControl?.sendActions(for: .valueChanged)
                
                let indexPath = IndexPath(row: 0, section: 0)
                self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                
            })
            .disposed(by: disposeBag)
        
        viewModel.output.itemSelected
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
}
