//
//  ListUserController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 14/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class ListUserController: UITableViewController {
    private let disposeBag = DisposeBag()
    private var viewModel: ListUserViewModel!
    private lazy var emptyView = EmptyView()
    
    convenience init(viewModel: ListUserViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerReusableCell(ListUserCell.self)
        tableView.rowHeight = 75
        tableView.estimatedRowHeight = 75
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        viewModel.output.searchedUser
            .do(onNext: { [unowned self](items) in
                self.tableView.backgroundView = nil
                if items.count == 0 {
                    self.emptyView.frame = self.tableView.bounds
                    self.tableView.backgroundView = self.emptyView
                } else {
                    self.tableView.backgroundView = nil
                }
            })
            .drive(tableView.rx.items) { tableView, row, item -> UITableViewCell in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ListUserCell.reuseIdentifier) as? ListUserCell else {
                    return UITableViewCell()
                }
                
                cell.tag = row
                cell.configureCell(item: ListUserCell.Input(user: item))
                
                return cell
            }
            .disposed(by: disposeBag)
        
        viewModel.output.filter
            .drive()
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(to: viewModel.input.itemSelectedI)
            .disposed(by: disposeBag)
        
        viewModel.output.itemSelectedO
            .drive()
            .disposed(by: disposeBag)
    }
}
