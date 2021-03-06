//
//  LinimasaController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import AlamofireImage

class LinimasaController: UIViewController {
    
    @IBOutlet weak var filter: UIButton!
    @IBOutlet weak var segmentedControl: SegementedControl!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var navbar: Navbar!
    var viewModel: LinimasaViewModel!
    
    lazy var pilpresViewModel = PilpresViewModel(navigator: viewModel.navigator, showTableHeader: true)
    lazy var janjiViewModel = JanpolListViewModel(navigator: viewModel.navigator, showTableHeader: true)
    
    private lazy var pilpresController = PilpresViewController(viewModel: pilpresViewModel)
    private lazy var janjiController = JanjiPolitikViewController(viewModel: janjiViewModel)
    
    private lazy var searchBar: UISearchBar = {
       let search = UISearchBar()
        search.searchBarStyle = .minimal
        search.sizeToFit()
        return search
    }()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        add(childViewController: pilpresController, context: container)
        add(childViewController: janjiController, context: container)
        
        // MARK
        // segmented control value
        // assign extension Reactive UIControl
        segmentedControl.rx.value
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] i in
                UIView.animate(withDuration: 0.3, animations: {
                    if i == 0 {
                        self.pilpresController.view.alpha = 1.0
                        self.janjiController.view.alpha = 0.0
                    } else {
                        self.pilpresController.view.alpha = 0.0
                        self.janjiController.view.alpha = 1.0
                    }
                })
            })
            .disposed(by: disposeBag)
    
        // MARK
        // bind to viewModel
        navbar.search.rx.tap
            .bind(to: viewModel.input.searchTrigger)
            .disposed(by: disposeBag)
        
        navbar.notification.rx.tap
            .bind(to: viewModel.input.notificationTrigger)
            .disposed(by: disposeBag)
        
        filter.rx.tap
            .map { [unowned self] (_) -> (type: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>) in
                return self.pilpresController.view.alpha == 1.0 ?
                    (type: .pilpres, filterTrigger: self.pilpresViewModel.input.filterTrigger) :
                    (type: .janji, filterTrigger: self.janjiViewModel.filterI)
            }
            .bind(to: viewModel.input.filterTrigger)
            .disposed(by: disposeBag)
    
        navbar.profile.rx.tap
            .bind(to: viewModel.input.profileTrigger)
            .disposed(by: disposeBag)
        
        navbar.note.rx.tap
            .bind(to: viewModel.input.catatanTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.filterSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.profileSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.catatanSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.filterSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.searchSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.userO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                let user = response.user
                if let thumbnail = user.avatar.thumbnail.url {
                    self.navbar.avatar.af_setImage(withURL: URL(string: thumbnail)!)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.updatesO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.notificationSelected
            .drive()
            .disposed(by: disposeBag)
        
        let left = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        left.direction = .left
        self.view.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        right.direction = .right
        self.view.addGestureRecognizer(right)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        viewModel.input.viewWillAppearTrigger.onNext(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc func swipeLeft() {
        self.segmentedControl.swipeLeft()

    }

    @objc func swipeRight() {
        self.segmentedControl.swipeRight()
    }
}
