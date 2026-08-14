//
//  HomeService.swift
//  SwiftNew
//
//  Created by QIAEN on 2026/8/14.
//

import Foundation

/// 首页 Dashboard 数据服务
class HomeService {
    static let shared = HomeService()
    private let network = NetworkManager.shared
    
    /// 获取首页聚合数据（活动轮播 / 素材 / 投稿）
    func getOverview(completion: @escaping (Result<BaseResponse<HomeDashboard>, NetworkError>) -> Void) {
        network.get(
            path: NetworkConstants.APIPath.dashboardOverview,
            parameters: nil,
            responseType: HomeDashboard.self,
            completion: completion
        )
    }
    
    /// 获取我的收益（已结算）
    func getMyRewards(
        pageNo: Int = 1,
        pageSize: Int = 20,
        completion: @escaping (Result<BaseResponse<RewardsData>, NetworkError>) -> Void
    ) {
        network.get(
            path: NetworkConstants.APIPath.myRewards,
            parameters: MyRewardsRequest(pageNo: pageNo, pageSize: pageSize),
            responseType: RewardsData.self,
            completion: completion
        )
    }
}
