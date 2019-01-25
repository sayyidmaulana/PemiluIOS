//
//  QuizController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import AlamofireImage

class QuizController: UITableViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    private var viewModel: QuizViewModel!
    lazy var tableHeaderView = HeaderQuizView()
    
    convenience init(viewModel: QuizViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.registerReusableCell(QuizCell.self)
        tableView.rowHeight = 350
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        viewModel.output.showHeader
            .drive(onNext: { [unowned self]isHeaderShown in
                if isHeaderShown {
                    self.tableView.tableHeaderView = self.tableHeaderView
                }
            })
            .disposed(by: disposeBag)
        
        tableHeaderView.config(viewModel: viewModel)
        
        viewModel.output.quizzes
            .bind(to: tableView.rx.items) { [unowned self]tableView, row, item -> UITableViewCell in
                // Loadmore trigger
                if row == self.viewModel.output.quizzes.value.count - 1 {
                    self.viewModel.input.nextPageTrigger.onNext(())
                }
                guard let cell = tableView.dequeueReusableCell(withIdentifier: QuizCell.reuseIdentifier) as? QuizCell else {
                    return UITableViewCell()
                }
                
                cell.configureCell(item: QuizCell.Input(viewModel: self.viewModel, quiz: item))
                cell.tag = row
                
                return cell
            }.disposed(by: disposeBag)
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.input.loadQuizTrigger.onNext(())
        
    }
    
    private func bindViewModel() {
        viewModel.output.openQuizSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.shareSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.infoSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.shareTrendSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.filter
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let headerView = tableView.tableHeaderView {
            
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            
            //Comparison necessary to avoid infinite loop
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }
}
