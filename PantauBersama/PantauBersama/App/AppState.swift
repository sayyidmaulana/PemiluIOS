//
//  AppState.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import Networking
import Common

final class AppState {
    
    class func local() -> PantauAuthResponse? {
        if let data: Data = UserDefaults.Account.get(forKey: .userData) {
            if let user = try? JSONDecoder().decode(PantauAuthResponse.self, from: data) {
                return user
            }
        }
        return nil
    }
    
    class func local<T: Codable>(key: UserDefaults.Account.AccountDefaultKey) -> Observable<T> {
        return UserDefaults.standard.rx
            .observe(Data.self,
                     UserDefaults.Account.AccountDefaultKey.userData.rawValue)
            .map { (data) -> T? in
                if let data: Data = UserDefaults.Account.get(forKey: key) {
                    if let user = try? JSONDecoder().decode(T.self, from: data) {
                        return user
                    }
                }
                return nil
            }
            .flatMapLatest({ $0.map({ Observable.just($0) }) ?? Observable.empty() })
    }
    
    class func save(_ data: PantauAuthResponse) {
        var response = data
        if let credential = data.data {
            UserDefaults.Account.set(credential.tokenType, forKey: .tokenType)
            KeychainService.save(type: NetworkKeychainKind.refreshToken, data: credential.refreshToken)
            KeychainService.save(type: NetworkKeychainKind.token, data: credential.accessToken)
        }
        response.data = nil
        if let jsonData = try? JSONEncoder().encode(data) {
            UserDefaults.Account.set(jsonData, forKey: .userData)
        }
    }
    
}