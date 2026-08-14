//
//  HomeBannerCarousel.swift
//  SwiftNew
//
//  Created by QIAEN on 2026/8/14.
//

import SwiftUI

/// 活动滚动轮播（复用 BannerBox 的自动播放 + 手势暂停逻辑）
struct HomeBannerCarousel: View {
    @EnvironmentObject var router: Router
    let events: [HomeEvent]
    
    @State private var isAutoPlay = true
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()
    
    private let boxHeight = 200.0
    
    var body: some View {
        if events.isEmpty {
            // 无活动时占位
            RoundedRectangle(cornerRadius: 15)
                .fill(.white)
                .frame(height: boxHeight)
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "sparkles.tv")
                            .font(.system(size: 30))
                            .foregroundStyle(.secondary)
                        Text("暂无进行中的活动")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }
        } else {
            TabView(selection: $currentIndex) {
                ForEach(Array(events.enumerated()), id: \.offset) { index, event in
                    CachedAsyncImage(urlString: event.bannerUrl) {
                        ZStack {
                            Color.gray.opacity(0.2)
                            ProgressView()
                        }
                    }
                    .frame(height: boxHeight)
                    .clipped()
                    .onTapGesture {
                        router.push(.eventDetail(eventId: event.id))
                    }
                    .tag(index)
                }
            }
            .frame(height: boxHeight)
            .tabViewStyle(.page(indexDisplayMode: .always))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        isAutoPlay = false
                    }
                    .onEnded { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            isAutoPlay = true
                        }
                    }
            )
            .onReceive(timer) { _ in
                guard isAutoPlay, events.count > 1 else { return }
                withAnimation {
                    currentIndex = (currentIndex + 1) % events.count
                }
            }
        }
    }
}
