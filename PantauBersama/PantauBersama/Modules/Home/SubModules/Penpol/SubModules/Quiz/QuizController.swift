//
//  QuizController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift

class QuizController: UITableViewController {
    private let disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerReusableCell(QuizCell.self)
        tableView.registerReusableCell(TrendCell.self)
        tableView.registerReusableCell(BannerInfoQuizCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .none
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension QuizController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 2 ? 30 : 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 85
        case 1:
            return 148
        default:
            return 350
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let bannerCell = tableView.dequeueReusableCell(indexPath: indexPath) as BannerInfoQuizCell
            return bannerCell
        case 1:
            let trendCell = tableView.dequeueReusableCell(indexPath: indexPath) as TrendCell
            return trendCell
        default:
            let quizCell = tableView.dequeueReusableCell(indexPath: indexPath) as QuizCell
            return quizCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
