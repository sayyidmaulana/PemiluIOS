//
//  QuizDetailCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

protocol QuizDetailNavigator {
    func startQuiz()
    var finish: Observable<Void>! { get set }
}

class QuizDetailCoordinator: BaseCoordinator<Void>, QuizDetailNavigator {
    var finish: Observable<Void>!
    
    private let navigationController: UINavigationController
    
    // TODO: replace any with Quiz model
    init(navigationController: UINavigationController, quizModel: Any) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = QuizDetailController()
        let viewModel = QuizDetailViewModel(navigator: self)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
    func startQuiz() {
        // TODO: Go to OngoingQuiz
    }
}
