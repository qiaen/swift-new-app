//
//  HomePage.swift
//  SwiftNew
//
//  Created by Qiaen on 2026/8/13.
//

import SwiftUI

/// 首页（参考 Web 端 overview.vue）
/// 模块顺序：活动轮播 → 素材 → 投稿 → 我的收益
struct HomePage: View {
    @EnvironmentObject var router: Router
    
    @State private var events: [HomeEvent] = []
    @State private var materials: [HomeMaterial] = []
    @State private var submissions: [HomeSubmission] = []
    @State private var rewards: [HomeReward] = []
    @State private var totalPaid: Double?
    @State private var totalPaidCurrency: String?
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                if StorageDefault.shared.hasToken() {
                    VStack(spacing: 16) {
                        // 1. 活动轮播
                        HomeBannerCarousel(events: events)
//                            .environmentObject(router)
                        
                        // 2. 素材
                        HomeMaterialsSection(materials: materials, isLoading: isLoading)
                        
                        // 3. 投稿
                        HomeSubmissionsSection(submissions: submissions, isLoading: isLoading)
                        
                        // 4. 我的收益
                        HomeRewardsSection(
                            rewards: rewards,
                            totalPaid: totalPaid,
                            totalPaidCurrency: totalPaidCurrency,
                            isLoading: isLoading
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom)
                } else {
                    NotLoginPage(pageTitle: "Home")
                        .padding(.top, 150)
                }
            }
            .background(.bgLightGray)
            .refreshable {
                await loadData()
            }
            .navigationDestination(for: Route.self) { route in
                RouterDestinationView(route: route)
            }
            .navigationTitle("Home")
            .task {
                guard StorageDefault.shared.hasToken() else { return }
                await loadData()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .networkUnauthorized)) { _ in
                router.popRoot()
                router.push(.login)
            }
    }
    
    private func loadData() async {
        // 并发请求：Dashboard 聚合数据 + 收益列表
        async let overview: Void = fetchOverview()
        async let rewardsData: Void = fetchRewards()
        _ = await (overview, rewardsData)
        isLoading = false
    }
    
    private func fetchOverview() async {
        await withCheckedContinuation { continuation in
            HomeService.shared.getOverview { result in
                switch result {
                case .success(let response):
                    if response.result, let data = response.data {
                        events = data.availableEvents
                        materials = data.mediaShortcuts
                        submissions = data.recentSubmissions
                    }
                case .failure(let error):
                    print("首页数据加载失败: \(error)")
                }
                continuation.resume()
            }
        }
    }
    
    private func fetchRewards() async {
        await withCheckedContinuation { continuation in
            HomeService.shared.getMyRewards { result in
                switch result {
                case .success(let response):
                    if response.result, let data = response.data {
                        rewards = data.list
                        totalPaid = data.totalPaid
                        totalPaidCurrency = data.totalPaidCurrency
                    }
                case .failure(let error):
                    print("收益数据加载失败: \(error)")
                }
                continuation.resume()
            }
        }
    }
}

#Preview {
    ContentView()
}
