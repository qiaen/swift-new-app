//
//  Discover.swift
//  SwiftNew
//
//  Created by QIAEN on 2026/8/14.
//

import SwiftUI

struct Discover: View {
    @EnvironmentObject var router: Router
    
    @State private var items: [DiscoverItem] = []
    @State private var isFirstLoad = true
    
    var body: some View {
        NavigationStack(path: $router.path) {
            List {
                ForEach(items) { item in
                    DiscoverCard(item: item)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .refreshable {
                await fetchData()
            }
            .overlay {
                if items.isEmpty && isFirstLoad {
                    ProgressView("加载中…")
                } else if items.isEmpty {
                    ContentUnavailableView(
                        "暂无数据",
                        systemImage: "arrow.clockwise",
                        description: Text("下拉可刷新")
                    )
                }
            }
            .padding(.bottom)
            .navigationTitle("Discover")
            .task {
                await fetchData()
            }
            .navigationDestination(for: Route.self) { route in
                RouterDestinationView(route: route)
            }
        }
    }
    
    private func fetchData() async {
        DiscoverService.shared.getDiscoverList { result in
            isFirstLoad = false
            switch result {
            case .success(let response):
                if response.result, let data = response.data {
                    items = data.list
                }
            case .failure(let error):
                print("获取活动列表失败: \(error)")
            }
        }
    }
}

// MARK: - 活动卡片
struct DiscoverCard: View {
    let item: DiscoverItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Banner 网络图片（带缓存）
            CachedAsyncImage(urlString: item.bannerUrl) {
                ZStack {
                    Color.gray.opacity(0.2)
                    ProgressView()
                }
            }
            .frame(height: 160)
            .clipped()
            .overlay(alignment: .topTrailing) {
                statusBadge
            }
            
            // 内容区
            VStack(alignment: .leading, spacing: 10) {
                Text(item.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                // 媒体平台：暂时用文字展示
                HStack(spacing: 10) {
                    ForEach(item.platforms.values, id: \.self) { platform in
                        Image(platform)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
                
                // 活动时间
                HStack(spacing: 4) {
                    Text(item.startAt)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    Text(item.endAt)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
        }
        .background(Color(.bgLightGray))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 8)
    }
    
    /// 状态角标
    private var statusBadge: some View {
        Text(item.eventStatus.displayName)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(item.eventStatus.badgeForeground)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(item.eventStatus.badgeBackground)
            )
            .padding(10)
    }
}

// MARK: - 活动状态扩展
extension EventStatus {
    var displayName: String {
        switch self {
        case .Active: return "进行中"
        case .Ended: return "已结束"
        case .unknown: return "未知"
        }
    }
    
    var badgeBackground: Color {
        switch self {
        case .Active: return Color.green.opacity(0.7)
        case .Ended: return Color.red.opacity(0.5)
        case .unknown: return Color.gray.opacity(0.5)
        }
    }
    
    var badgeForeground: Color {
        switch self {
        case .Active: return Color.white
        case .Ended: return Color.white
        case .unknown: return Color.white
        }
    }
}

#Preview {
    ContentView()
}
