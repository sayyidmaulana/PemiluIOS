//
//  MyJanpolListViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 12/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

class MyJanpolListViewModel: IJanpolListViewModel, IJanpolListViewModelInput, IJanpolListViewModelOutput {
    
    var input: IJanpolListViewModelInput { return self }
    var output: IJanpolListViewModelOutput { return self }
    
    var refreshI: AnyObserver<Void>
    var nextPageI: AnyObserver<Void>
    var shareJanjiI: AnyObserver<Any>
    var moreI: AnyObserver<JanjiPolitik>
    var moreMenuI: AnyObserver<JanjiType>
    var itemSelectedI: AnyObserver<IndexPath>
    var filterI: AnyObserver<[PenpolFilterModel.FilterItem]>
    
    var items: Driver<[ICellConfigurator]>!
    var error: Driver<Error>!
    var moreSelectedO: Driver<JanjiPolitik>!
    var moreMenuSelectedO: Driver<Void>!
    var itemSelectedO: Driver<Void>!
    var shareSelectedO: Driver<Void>!
    var filterO: Driver<Void>!
    var bannerO: Driver<BannerInfo>!
    var bannerSelectedO: Driver<Void>!
    
    private let refreshSubject = PublishSubject<Void>()
    private let moreSubject = PublishSubject<JanjiPolitik>()
    private let moreMenuSubject = PublishSubject<JanjiType>()
    private let shareSubject = PublishSubject<Any>()
    private let nextSubject = PublishSubject<Void>()
    private let itemSelectedSubject = PublishSubject<IndexPath>()
    private let filterSubject = PublishSubject<[PenpolFilterModel.FilterItem]>()
    
    internal let errorTracker = ErrorTracker()
    internal let activityIndicator = ActivityIndicator()
    internal let headerViewModel = BannerHeaderViewModel()
    
    private var filterItems: [PenpolFilterModel.FilterItem] = []
    
    init(navigator: IJanpolNavigator) {
        refreshI = refreshSubject.asObserver()
        nextPageI = nextSubject.asObserver()
        moreI = moreSubject.asObserver()
        moreMenuI = moreMenuSubject.asObserver()
        shareJanjiI = shareSubject.asObserver()
        itemSelectedI = itemSelectedSubject.asObserver()
        filterI = filterSubject.asObserver()
        
        error = errorTracker.asDriver()
        
        let janpolItems = refreshSubject.startWith(())
            .flatMapLatest { [unowned self] (_) -> Observable<[JanjiPolitik]> in
//                let cid = self.filterItems.filter({ $0.paramKey == "cluster_id"}).first?.paramValue
//                let filter = self.filterItems.filter({ $0.paramKey == "filter_by"}).first?.paramValue
                
                return self.paginateItems(nextBatchTrigger: self.nextSubject.asObservable(), cid: "", filter: "")
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .catchErrorJustReturn([])
            }
            .asDriver(onErrorJustReturn: [])
        
        // MARK:
        // Map feeds response to cell list
        items = janpolItems
            .map { (list) -> [ICellConfigurator] in
                return list.map({ janpol -> ICellConfigurator in
                    return LinimasaJanjiCellConfigured(item: LinimasaJanjiCell.Input(viewModel: self, janpol: janpol))
                })
        }
        
        itemSelectedO = itemSelectedSubject
            .withLatestFrom(janpolItems) { (indexPath, items) -> JanjiPolitik in
                return items[indexPath.row]
            }
            .flatMapLatest({ navigator.launchJanjiDetail(data: $0) })
            .asDriverOnErrorJustComplete()
        
        moreSelectedO = moreSubject
            .asObserver().asDriverOnErrorJustComplete()
        
        shareSelectedO = shareSubject
            .flatMapLatest({ _ in navigator.shareJanji(data: "Any") })
            .asDriver(onErrorJustReturn: ())
        
        moreMenuSelectedO = moreMenuSubject
            .flatMapLatest { (type) -> Observable<Void> in
                switch type {
                case .bagikan:
                    return navigator.shareJanji(data: "as")
                case .salin:
                    return navigator.shareJanji(data: "as")
                case .hapus(let id):
                    return self.delete(id: id).mapToVoid()
                default:
                    return Observable.empty()
                }
            }
            .asDriverOnErrorJustComplete()
        
        filterO = filterSubject
            .do(onNext: { [weak self] (filterItems) in
                guard let `self` = self else { return  }
                print("Filter \(filterItems)")
                
                let filter = filterItems.filter({ (filterItem) -> Bool in
                    return filterItem.id.contains("janji")
                })
                
                if !filter.isEmpty {
                    self.filterItems = filterItems
                }
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        bannerO = refreshSubject.startWith(())
            .flatMapLatest({ self.bannerInfo() })
            .asDriverOnErrorJustComplete()
        
        bannerSelectedO = headerViewModel.output.itemSelected
            .asObservable()
            .flatMapLatest({ (banner) -> Observable<Void> in
                return navigator.launchBannerInfo(bannerInfo: banner)
            })
            .asDriverOnErrorJustComplete()
        
    }
    
    func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>, cid: String, filter: String) ->
        Observable<Page<[JanjiPolitik]>> {
            return NetworkService.instance
                .requestObject(LinimasaAPI.getMyJanjiPolitiks(query: filter, page: batch.page, perPage: batch.limit),
                               c: BaseResponse<JanjiPolitikResponse>.self)
                .map({ self.transformToPage(response: $0, batch: batch) })
                .asObservable()
                .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                    return result.batch.next().hasNextPage
                }, nextPageFactory: { (result) -> Observable<Page<[JanjiPolitik]>> in
                    self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger, cid: cid, filter: filter)
                })
                .share(replay: 1, scope: .whileConnected)
            
    }
    
    private func bannerInfo() -> Observable<BannerInfo> {
        return NetworkService.instance
            .requestObject(
                LinimasaAPI.getBannerInfos(pageName: "janji politik"),
                c: BaseResponse<BannerInfoResponse>.self
            )
            .map{ ($0.data.bannerInfo) }
            .asObservable()
            .catchErrorJustComplete()
    }
    
    
}