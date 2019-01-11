//
//  UndangAnggotaViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 26/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

class UndangAnggotaViewModel: ViewModelType {
    var input: Input
    var output: Output
    
    struct Input {
        let backTrigger: AnyObserver<Void>
        let undangTrigger: AnyObserver<Void>
        let switchTrigger: BehaviorSubject<Bool>
        let switchLabelTrigger: AnyObserver<String>
    }
    
    struct Output {
        let createSelected: Driver<Void>
        let switchSelected: Driver<Void>
        let switchLabelSelected: Driver<String>
        let userData: Driver<User>
    }
    
    private let undangSubject = PublishSubject<Void>()
    private let backSubject = PublishSubject<Void>()
    private let switchSubject = BehaviorSubject<Bool>(value: false)
    private let switchLabelSubject = PublishSubject<String>()
    
    var navigator: UndangAnggotaNavigator
    private let data: User
    
    init(navigator: UndangAnggotaNavigator, data: User) {
        self.navigator = navigator
        self.navigator.finish = backSubject
        self.data = data
        
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        input = Input(backTrigger: backSubject.asObserver(),
                      undangTrigger: undangSubject.asObserver(),
                      switchTrigger: switchSubject.asObserver(),
                      switchLabelTrigger: switchLabelSubject.asObserver())
        
        let create = undangSubject
            .asDriver(onErrorJustReturn: ())
        
        
        let magicLink = switchSubject
            .flatMapLatest { (value) -> Observable<Void> in
                print(value)
                return NetworkService.instance
                    .requestObject(PantauAuthAPI
                        .clusterMagicLink(id: data.cluster?.id ?? "",
                                          enable: value),
                                   c: BaseResponse<SingleCluster>.self)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asObservable()
                    .catchErrorJustComplete()
                    .mapToVoid()
            }
        
        let label = switchLabelSubject
            .asDriverOnErrorJustComplete()
        
        
        output = Output(createSelected: create,
                        switchSelected: magicLink.asDriverOnErrorJustComplete(),
                        switchLabelSelected: label,
                        userData: Driver.just(data))
    }
    
}
