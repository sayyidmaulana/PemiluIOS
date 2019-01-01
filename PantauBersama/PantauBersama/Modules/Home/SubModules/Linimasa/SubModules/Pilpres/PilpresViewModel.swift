//
//  PilpresViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 26/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

class PilpresViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let refreshTrigger: AnyObserver<Void>
        let moreTrigger: AnyObserver<Feeds>
        let moreMenuTrigger: AnyObserver<PilpresType>
        let nextTrigger: AnyObserver<Void>
        let viewWillAppearTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let feedsCells: Driver<[ICellConfigurator]>
        let moreSelected: Driver<Feeds>
        let moreMenuSelected: Driver<Void>
        let bannerInfo: Driver<BannerInfo>
        let infoSelected: Driver<Void>
    }
    
    private let refreshSubject = PublishSubject<Void>()
    private let moreSubject = PublishSubject<Feeds>()
    private let moreMenuSubject = PublishSubject<PilpresType>()
    private let nextSubject = PublishSubject<Void>()
    private let viewWillAppearSubject = PublishSubject<Void>()
    
    private let navigator: PilpresNavigator
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    let headerViewModel = BannerHeaderViewModel()
    
    init(navigator: LinimasaNavigator) {
        self.navigator = navigator
        
        input = Input(
            refreshTrigger: refreshSubject.asObserver(),
            moreTrigger: moreSubject.asObserver(),
            moreMenuTrigger: moreMenuSubject.asObserver(),
            nextTrigger: nextSubject.asObserver(),
            viewWillAppearTrigger: viewWillAppearSubject.asObserver())
        
        let bannerInfo = viewWillAppearSubject
            .flatMapLatest({ self.bannerInfo() })
            .asDriverOnErrorJustComplete()
        
        // MARK:
        // Get feeds pagination
        let feedsItems = refreshSubject.startWith(())
            .flatMapLatest { [unowned self] (_) -> Observable<[Feeds]> in
                return self.paginateItems(nextBatchTrigger: self.nextSubject.asObservable())
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .catchErrorJustReturn([])
            }
            .asDriver(onErrorJustReturn: [])
        
        // MARK:
        // Map feeds response to cell list
        let feedsCells = feedsItems
            .map { (list) -> [ICellConfigurator] in
                return list.map({ (feeds) -> ICellConfigurator in
                    return LinimasaCellConfigured(item: LinimasaCell.Input(viewModel: self, feeds: feeds))
                })
            }
        
        let moreSelected = moreSubject
            .asObserver().asDriverOnErrorJustComplete()
    
        let moreMenuSelected = moreMenuSubject
            .flatMapLatest({ (type) -> Observable<Void> in
                switch type {
                case .salin:
                    return navigator.sharePilpres(data: "data")
                case .bagikan:
                    return navigator.sharePilpres(data: "bagi")
                case .twitter:
                    return navigator.openTwitter(data: "www.twitter.com")
                }
            })
            .asDriverOnErrorJustComplete()
        
        let infoSelected = headerViewModel.output.itemSelected
            .asObservable()
            .flatMapLatest({ (banner) -> Observable<Void> in
                return navigator.launchBannerInfo(bannerInfo: banner)
            })
            .asDriverOnErrorJustComplete()
        
        output = Output(feedsCells: feedsCells,
                        moreSelected: moreSelected,
                        moreMenuSelected: moreMenuSelected,
                        bannerInfo: bannerInfo,
                        infoSelected: infoSelected)
        
    }
    
    private func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>) -> Observable<[Feeds]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    private func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>) ->
        Observable<Page<[Feeds]>> {
            return NetworkService.instance
                .requestObject(LinimasaAPI.getFeeds(page: batch.page, perPage: batch.limit),
                               c: BaseResponse<FeedsResponse>.self)
                .map({ self.transformToPage(response: $0, batch: batch) })
                .asObservable()
                .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                    return result.batch.next().hasNextPage
                }, nextPageFactory: { (result) -> Observable<Page<[Feeds]>> in
                    self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger)
                })
                .share(replay: 1, scope: .whileConnected)
            
    }
    
    private func transformToPage(response: BaseResponse<FeedsResponse>, batch: Batch) -> Page<[Feeds]> {
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage ?? 10,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[Feeds]>(
            item: response.data.feeds,
            batch: nextBatch
        )
    }
    
    
    private func bannerInfo() -> Observable<BannerInfo> {
        return NetworkService.instance
            .requestObject(
                LinimasaAPI.getBannerInfos(pageName: "pilpres"),
                c: BaseResponse<BannerInfoResponse>.self
            )
            .map{ ($0.data.bannerInfo) }
            .asObservable()
            .catchErrorJustComplete()
    }
}


