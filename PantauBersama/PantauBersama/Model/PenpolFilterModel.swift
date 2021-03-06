//
//  PenpolFilterModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 07/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift

enum FilterViewType: String {
    case radio = "radio"
    case text = "text"
}

struct PenpolFilterModel {
    let paramKey: String
    let title: String
    let items: [FilterItem]
    
    struct FilterItem {
        let id: String
        let paramKey: String
        var paramValue: String
        let title: String
        let type: FilterViewType
        var isSelected: Bool
    }
}

extension PenpolFilterModel {
    static func generateQuestionFilter() -> [PenpolFilterModel] {
        var filterItems: [PenpolFilterModel] = []
        
        let all = FilterItem(id: "question-all", paramKey: "filter_by", paramValue: "user_verified_all", title: "Semua", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "question-all"))
        let notVerified = FilterItem(id: "question-notverified", paramKey: "filter_by", paramValue: "user_verified_false", title: "Belum Verifikasi", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "question-notverified"))
        let verified = FilterItem(id: "question-verified", paramKey: "filter_by", paramValue: "user_verified_true", title: "Terverifikasi", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "question-verified"))
        let userFilter = PenpolFilterModel(paramKey: "filter_by", title: "User", items: [all, notVerified, verified])
        
        let newest = FilterItem(id: "question-newest", paramKey: "order_by", paramValue: "created_at", title: "Paling Baru", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "question-newest"))
        let voteCount = FilterItem(id: "question-votecount", paramKey: "order_by", paramValue: "cached_votes_up", title: "Paling Banyak Divoting", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "question-votecount"))
        let orderFilter = PenpolFilterModel(paramKey: "order_by", title: "Urutan", items: [newest, voteCount])
        
        filterItems.append(userFilter)
        filterItems.append(orderFilter)
        
        return filterItems
    }
    
    static func generateLatestItemQuestion() -> FilterItem {
        let newest = FilterItem(id: "question-newest", paramKey: "order_by", paramValue: "created_at", title: "Paling Baru", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "question-newest"))
        return newest
    }
    

    static func generatePilpresFilter() -> [PenpolFilterModel] {
        var filterItems: [PenpolFilterModel] = []
        
        let all = FilterItem(id: "pilpres-teamall", paramKey: "filter_by", paramValue: "team_all", title: "Semua", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "pilpres-teamall"))
        let paslonSatu = FilterItem(id: "pilpres-paslonsatu", paramKey: "filter_by", paramValue: "team_id_1", title: "Tim Jokowi - Ma'ruf", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "pilpres-paslonsatu"))
        let paslonDua = FilterItem(id: "pilpres-paslondua", paramKey: "filter_by", paramValue: "team_id_2", title: "Tim Prabowo - Sandi", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "pilpres-paslondua"))
        let kpu = FilterItem(id: "pilpres-paslontiga", paramKey: "filter_by", paramValue: "team_id_3", title: "KPU", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "pilpres-paslontiga"))
        let bawaslu = FilterItem(id: "pilpres-paslonempat", paramKey: "filter_by", paramValue: "team_id_4", title: "Bawaslu", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "pilpres-paslonempat"))
        let sumberFilter = PenpolFilterModel(paramKey: "filter_by", title: "Sumber", items: [all, paslonSatu, paslonDua, kpu, bawaslu])
        filterItems.append(sumberFilter)
        return filterItems
    }
    
    static func generateJanjiFilter() -> [PenpolFilterModel] {
        var filterItems: [PenpolFilterModel] = []
        
        // TODO: TBD The key for this item is the same with quiz filter
        let cachedCluster = UserDefaults.getClusterFilter()
        let cachedClusterId = cachedCluster?["id"]
        
        let cluster = FilterItem(id: "janji-cluster", paramKey: "cluster_id", paramValue: cachedClusterId ?? "", title: "Cluster", type: .text, isSelected: false)
        let clusterFilter = PenpolFilterModel(paramKey: "cluster_id", title: "Cluster", items: [cluster])
        let all = FilterItem(id: "janji-all", paramKey: "filter_by", paramValue: "user_verified_all", title: "Semua", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "janji-all"))
        let notVerified = FilterItem(id: "janji-notverified", paramKey: "filter_by", paramValue: "user_verified_false", title: "Belum Verifikasi", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "janji-notverified"))
        let verified = FilterItem(id: "janji-verified", paramKey: "filter_by", paramValue: "user_verified_true", title: "Terverifikasi", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "janji-verified"))
        let userFilter = PenpolFilterModel(paramKey: "filter_by", title: "User", items: [all, notVerified, verified])
        
        filterItems.append(clusterFilter)
        filterItems.append(userFilter)
        
        return filterItems
    }
    
    static func generateClusterFilter() -> [PenpolFilterModel] {
        var filterItems: [PenpolFilterModel] = []
        
        let cachedCategory = UserDefaults.getCategoryFilter()
        let cachedCategoryId = cachedCategory?["id"]
        let category = FilterItem(id: "cluster-categories", paramKey: "filter_value", paramValue: cachedCategoryId ?? "", title: "Kategori", type: .text, isSelected: false)
        let categoryFilter = PenpolFilterModel(paramKey: "filter_value", title: "Kategori", items: [category])
        
        filterItems.append(categoryFilter)
        
        return filterItems
    }

    static func generateQuizFilter() -> [PenpolFilterModel] {
        var filterItems: [PenpolFilterModel] = []
        
        let all = FilterItem(id: "quiz-all", paramKey: "filter_by", paramValue: "all", title: "Semua", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "quiz-all"))
        let notParticipating = FilterItem(id: "quiz-notparticipating", paramKey: "filter_by", paramValue: "not_participating", title: "Belum Diikuti", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "quiz-notparticipating"))
        let inProgress = FilterItem(id: "quiz-inprogress", paramKey: "filter_by", paramValue: "in_progress", title: "Belum Selesai", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "quiz-inprogress"))
        let finished = FilterItem(id: "quiz-finished", paramKey: "filter_by", paramValue: "finished", title: "Selesai", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "quiz-finished"))
        let quizFilter = PenpolFilterModel(paramKey: "filter_by", title: "Quiz", items: [all, notParticipating, inProgress, finished])
        
        filterItems.append(quizFilter)
        
        return filterItems
    }
    
    static func generateUsersFilter() -> [PenpolFilterModel] {
        var filterItems: [PenpolFilterModel] = []
        
        let all = FilterItem(id: "user-all", paramKey: "filter_by", paramValue: "verified_all", title: "Semua", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "user-all"))
        let notVerified = FilterItem(id: "user-notverified", paramKey: "filter_by", paramValue: "verified_false", title: "Belum Verifikasi", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "user-notverified"))
        let verified = FilterItem(id: "user-verified", paramKey: "filter_by", paramValue: "verified_true", title: "Terverifikasi", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "user-verified"))
        let userFilter = PenpolFilterModel(paramKey: "filter_by", title: "User", items: [all, notVerified, verified])
        
        filterItems.append(userFilter)
        
        return filterItems
    }
}
