//
//  LinimasaViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Networking
import Common

final class LinimasaViewModel: ViewModelType {

    var input: Input
    var output: Output
    
    struct Input {
        let searchTrigger: AnyObserver<Void>
        let filterTrigger: AnyObserver<(type: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>)>
        let refreshTrigger: AnyObserver<Void>
        let profileTrigger: AnyObserver<Void>
        let viewWillAppearTrigger: AnyObserver<Void>
        let catatanTrigger: AnyObserver<Void>
        let notificationTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let searchSelected: Driver<Void>
        let filterSelected: Driver<Void>
        let profileSelected: Driver<Void>
        let userO: Driver<UserResponse>
        let catatanSelected: Driver<Void>
        let updatesO: Driver<Void>
        let notificationSelected: Driver<Void>
    }
    
    let navigator: LinimasaNavigator
    private let filterSubject = PublishSubject<(type: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>)>()
    private let refreshSubject = PublishSubject<Void>()
    private let profileSubject = PublishSubject<Void>()
    private let viewWillppearS = PublishSubject<Void>()
    private let searchSubject = PublishSubject<Void>()
    private let catatanS = PublishSubject<Void>()
    private let activityIndicator = ActivityIndicator()
    private let errorTracker = ErrorTracker()
    private let notificationS = PublishSubject<Void>()
    
    init(navigator: LinimasaNavigator) {
        self.navigator = navigator
        
        
        input = Input(
            searchTrigger: searchSubject.asObserver(),
            filterTrigger: filterSubject.asObserver(),
            refreshTrigger: refreshSubject.asObserver(),
            profileTrigger: profileSubject.asObserver(),
            viewWillAppearTrigger: viewWillppearS.asObserver(),
            catatanTrigger: catatanS.asObserver(),
            notificationTrigger: notificationS.asObserver()
        )
        
        let filter = filterSubject
            .flatMap({ navigator.launchFilter(filterType: $0.type, filterTrigger: $0.filterTrigger)})
            .asDriver(onErrorJustReturn: ())
        
        let profile = profileSubject
            .flatMapLatest({ navigator.launchProfile(isMyAccount: true, userId: nil) })
            .asDriver(onErrorJustReturn: ())
        
        let note = catatanS
            .flatMapLatest({ navigator.launchNote() })
            .asDriver(onErrorJustReturn: ())
        
        let search = searchSubject
            .flatMapLatest({ navigator.launchSearch() })
            .asDriver(onErrorJustReturn: ())
        
        // MARK
        // Get local user response
//        let cloud = NetworkService.instance.requestObject(
//            PantauAuthAPI.me,
//            c: BaseResponse<UserResponse>.self)
//            .map({ $0.data })
//            .do(onSuccess: { (response) in
//                AppState.saveMe(response)
//            })
//            .trackError(errorTracker)
//            .trackActivity(activityIndicator)
//            .asObservable()
//            .catchErrorJustComplete()
        
        let local: Observable<UserResponse> = AppState.local(key: .me)
        let userData = viewWillppearS
            .flatMapLatest({ local })
            .asDriverOnErrorJustComplete()
        
        // TODO
        // Check for updates minor, feature and force
        let newVersion = NetworkService.instance
            .requestObject(LinimasaAPI.appVersions(type: "ios"),
                           c: BaseResponse<AppVersionResponse>.self)
            .map({ $0.data })
            .do(onSuccess: { (response) in
                AppState.saveVersion(response)
            })
            .asObservable()
            .catchErrorJustComplete()
        
        let versions = viewWillppearS.flatMapLatest({ newVersion })
            .flatMapLatest { (version) -> Observable<Void> in
                if let newVersion = version.app.version {
                    let state = newVersion.compare(versionString(), options: .numeric) == .orderedDescending
                    if state == true && version.app.forceUpdate == true {
                        return navigator.launchUpdates(type: .major)
                    } else if state == true {
                        // check from condition skip
                        if let conditionSkip: Bool = UserDefaults.Account.get(forKey: .skipVersion) {
                            if conditionSkip == true {
                                return Observable.empty()
                            } else {
                                return navigator.launchUpdates(type: .minor)
                            }
                        }
                    }
                }
                return Observable.empty()
            }
        
        let notification = notificationS
            .flatMapLatest({ navigator.launchNotifications() })
            .asDriverOnErrorJustComplete()
        
        output = Output(searchSelected: search,
                        filterSelected: filter,
                        profileSelected: profile,
                        userO: userData,
                        catatanSelected: note,
                        updatesO: versions.asDriverOnErrorJustComplete(),
                        notificationSelected: notification
        )
    }
    
}
