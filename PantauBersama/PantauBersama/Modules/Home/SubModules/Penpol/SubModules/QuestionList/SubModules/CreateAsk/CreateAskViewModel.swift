//
//  CreateAskViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

class CreateAskViewModel: ViewModelType {
    var input: Input
    var output: Output!
    
    struct Input {
        let backTrigger: AnyObserver<Void>
        let createTrigger: AnyObserver<Void>
        let questionInput: BehaviorRelay<String>
    }
    
    struct Output {
        let createSelected: Driver<Void>
        let userData: Driver<UserResponse?>
        let loadingIndicator: Driver<Bool>
        let enableO: Driver<Bool>
    }
    
    private let createSubject = PublishSubject<Void>()
    private let backSubject = PublishSubject<Void>()
    private let questionRelay = BehaviorRelay<String>(value: "")
    
    private let activityIndicator = ActivityIndicator()
    private let errorTracker = ErrorTracker()
    private let disposeBag = DisposeBag()
    
    var navigator: CreateAskNavigator
    
    init(navigator: CreateAskNavigator) {
        self.navigator = navigator
        
        input = Input(backTrigger: backSubject.asObserver(),
                      createTrigger: createSubject.asObserver(),
                      questionInput: questionRelay)

        let create = createSubject
            .flatMap({ self.createQuestion() })
            .mapToVoid()
            .trackActivity(activityIndicator)
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
        
        self.navigator.back = backSubject
        
        self.navigator.createComplete = create.asObservable()

        
        // MARK
        // Get user data from userDefaults
        let userData: Data? = UserDefaults.Account.get(forKey: .me)
        let userResponse = try? JSONDecoder().decode(UserResponse.self, from: userData ?? Data())
        let user = Observable.just(userResponse).asDriverOnErrorJustComplete()
        
        let enable = questionRelay
            .map { (s) -> Bool in
                return s.count > 0 && !s.containsInsensitive("Tulis pertanyaan terbaikmu di sini!")
            }.startWith(false)
            .asDriverOnErrorJustComplete()

        output = Output(createSelected: create,
                        userData: user,
                        loadingIndicator: activityIndicator.asDriver(),
                        enableO: enable)
    }
    
    private func createQuestion() -> Observable<QuestionModel> {
        return NetworkService.instance
            .requestObject(TanyaKandidatAPI.createQuestion(body: questionRelay.value), c: QuestionResponse.self)
            .map({ (questionResponse) -> QuestionModel in
                return QuestionModel(question: questionResponse.data.question)
            })
            .asObservable()
            .catchErrorJustComplete()
    }
    
}
