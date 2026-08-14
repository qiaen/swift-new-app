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
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name).font(.headline)
                            Text(item.startAt).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .refreshable {
                // 下拉触发，这里处于 async 环境
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
            .navigationTitle("Discover")
            .task {
                await fetchData()
            }
            .navigationDestination(for: Route.self) { route in
                // 重点：导航目标由它生成
                RouterDestinationView(route: route)
            }
        }
        
    }
    private func fetchData() async {
        // 使用 Service
        DiscoverService.shared.getDiscoverList(eventStatus: .Active) { result in
            isFirstLoad = false

            switch result {
            case .success(let response):
                if response.result, let data = response.data {
                    items = data.list
                } else {
                    
                }
            case .failure(let error):
                print("")
            }
        }
    }

    private struct Item: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
    }
}

#Preview {
    ContentView()
}
