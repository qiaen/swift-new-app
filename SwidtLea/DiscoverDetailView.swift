//
//  DiscoverDetailView.swift
//  SwiftNew
//
//  Created by QIAEN on 2026/8/14.
//

import SwiftUI

/// 活动详情页（参考 Web 端 act-details.vue）
struct DiscoverDetailView: View {
    let eventId: String
    
    @State private var detail: EventDetail?
    @State private var materials: [MaterialItem] = []
    @State private var isLoading = true
    @State private var loadFailed = false
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("加载中…")
                    .frame(maxWidth: .infinity, minHeight: 300)
            } else if let detail {
                content(detail)
            } else if loadFailed {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("加载失败")
                        .font(.headline)
                    Button("重试") {
                        Task { await loadData() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, minHeight: 300)
            }
        }
        .background(.bgLightGray)
        .navigationTitle("活动详情")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            await loadData()
        }
    }
    
    @ViewBuilder
    private func content(_ detail: EventDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // 信息卡片
            VStack(alignment: .leading, spacing: 0) {
                // Banner
                CachedAsyncImage(urlString: detail.bannerUrl) {
                    ZStack {
                        Color.gray.opacity(0.2)
                        ProgressView()
                    }
                }
                .frame(height: 180)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    statusBadge(detail)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // 标题
                    Text(detail.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    // 信息列表
                    infoRow(
                        icon: "calendar",
                        title: "提交窗口",
                        value: "\(detail.startAt.toLocalTimeString()) → \(detail.endAt.toLocalTimeString())"
                    )
                    
                    infoRow(
                        icon: "globe.asia.australia",
                        title: "地区",
                        value: detail.countryScope.values.joined(separator: ", ")
                    )
                    
                    // 平台
                    if !detail.platforms.values.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("平台")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                            HStack(spacing: 8) {
                                ForEach(detail.platforms.values, id: \.self) { platform in
                                    Image(platform)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(.white))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // 活动规则
            VStack(alignment: .leading, spacing: 12) {
                Text("活动规则")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text(detail.rulesText.isEmpty ? "暂无规则" : detail.rulesText)
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color(.white))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            // 活动素材
            if !materials.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("活动素材")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                        spacing: 12
                    ) {
                        ForEach(materials) { material in
                            MaterialCard(material: material)
                        }
                    }
                }
                .padding(16)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    /// 状态角标
    private func statusBadge(_ detail: EventDetail) -> some View {
        Text(detail.eventStatus.displayName)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(detail.eventStatus.badgeForeground)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(detail.eventStatus.badgeBackground))
            .padding(10)
    }
    
    /// 信息行
    private func infoRow(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 13))
            }
            .foregroundStyle(.secondary)
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func loadData() async {
        isLoading = true
        loadFailed = false
        
        await withCheckedContinuation { continuation in
            DiscoverService.shared.getEventDetail(eventId: eventId) { result in
                switch result {
                case .success(let response):
                    if response.result, let event = response.data?.event {
                        detail = event
                    } else {
                        loadFailed = true
                    }
                case .failure(let error):
                    print("获取活动详情失败: \(error)")
                    loadFailed = true
                }
                continuation.resume()
            }
        }
        
        await withCheckedContinuation { continuation in
            DiscoverService.shared.getMaterials(eventId: eventId) { result in
                if case .success(let response) = result, response.result {
                    materials = response.data?.list ?? []
                }
                continuation.resume()
            }
        }
        
        isLoading = false
    }
}

// MARK: - 素材卡片
struct MaterialCard: View {
    let material: MaterialItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 缩略图
            if let thumb = material.thumbnailUrl, !thumb.isEmpty {
                CachedAsyncImage(urlString: thumb) {
                    placeholder
                }
                .frame(height: 90)
                .clipped()
            } else {
                placeholder
                    .frame(height: 90)
            }
            
            Text(material.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            HStack(spacing: 4) {
                Text(material.type)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                if let size = material.fileSize, size > 0 {
                    Text("·")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    Text(size.fileSizeString)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.bgLightGray))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var placeholder: some View {
        ZStack {
            Color.gray.opacity(0.15)
            Image(systemName: "doc.zipper")
                .font(.system(size: 24))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 工具扩展
extension String {
    /// UTC 时间字符串转本地时间 "yyyy-MM-dd HH:mm"，解析失败原样返回
    func toLocalTimeString() -> String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = iso.date(from: self) else { return self }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}

extension Double {
    /// 文件大小展示，如 1.2 MB
    var fileSizeString: String {
        ByteCountFormatter.string(fromByteCount: Int64(self), countStyle: .file)
    }
}

#Preview {
    NavigationStack {
        DiscoverDetailView(eventId: "38085bf1814144dfa66ad7e126d4d21a")
    }
}
