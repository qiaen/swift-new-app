//
//  Discover.swift
//  SwiftNew
//
//  Created by QIAEN on 2026/8/14.
//

import SwiftUI

struct Discover: View {
    @EnvironmentObject var router: Router
    
    @State private var items: [Item] = []
    @State private var isFirstLoad = true
    
    var body: some View {
        
        NavigationStack(path: $router.path) {
            List {
                ForEach(items) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title).font(.headline)
                            Text(item.subtitle).font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "bell.fill").foregroundStyle(.tint)
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
        // 模拟请求，替换成真实接口调用即可
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        let time = Date.now.formatted(date: .omitted, time: .standard)
        items = (1...15).map { Item(title: "第 \($0) 条通知", subtitle: "更新时间 \(time)") }
        isFirstLoad = false
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
