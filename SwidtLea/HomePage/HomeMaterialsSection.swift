//
//  HomeMaterialsSection.swift
//  SwiftNew
//
//  Created by QIAEN on 2026/8/14.
//

import SwiftUI

/// 素材模块（对应 dsMaterials：mediaShortcuts）
struct HomeMaterialsSection: View {
    let materials: [HomeMaterial]
    var isLoading = false
    
    var body: some View {
        HomeSectionBox(title: "素材") {
            if isLoading {
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.bgLightGray)
                            .frame(width: 140, height: 150)
                            .overlay(ProgressView())
                    }
                }
            } else if materials.isEmpty {
                Text("暂无素材")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(materials) { material in
                            HomeMaterialCard(material: material)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }
}

/// 单个素材卡片
struct HomeMaterialCard: View {
    let material: HomeMaterial
    private let thumbWidth: CGFloat = 160
    private let thumbHeight: CGFloat = 90
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 缩略图 + 类型/大小角标
            ZStack(alignment: .bottomLeading) {
                if let thumb = material.thumbnailUrl, !thumb.isEmpty {
                    CachedAsyncImage(urlString: thumb) {
                        placeholder
                    }
                } else {
                    placeholder
                }
            }
            .frame(width: thumbWidth, height: thumbHeight)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(alignment: .topTrailing) {
                if let size = material.fileSize, size > 0 {
                    Text(size.fileSizeString)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.black.opacity(0.45), in: Capsule())
                        .padding(6)
                }
            }
            .overlay(alignment: .bottomLeading) {
                if let type = material.type, !type.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: Self.iconName(for: type))
                            .font(.system(size: 9))
                        Text(type)
                    }
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.black.opacity(0.45), in: Capsule())
                    .padding(6)
                }
            }
            
            Text(material.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            
            // gameCode · 文件大小
            HStack(spacing: 5) {
                if let game = material.gameCode, !game.isEmpty {
                    Image(systemName: "gamecontroller")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    Text(game)
                        .lineLimit(1)
                }
                if let size = material.fileSize, size > 0 {
                    if material.gameCode?.isEmpty == false {
                        Text("·")
                            .foregroundStyle(.tertiary)
                    }
                    Text(size.fileSizeString)
                        .lineLimit(1)
                }
            }
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(width: 180, alignment: .leading)
        .background(Color(.bgLightGray))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private var placeholder: some View {
        ZStack {
            LinearGradient(
                colors: [Color.gray.opacity(0.12), Color.gray.opacity(0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "photo")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
        }
    }
    
    /// 根据素材类型返回 SF Symbol 图标名
    private static func iconName(for type: String) -> String {
        switch type.lowercased() {
        case "video", "mp4", "mov", "m4v":
            return "film"
        case "image", "png", "jpg", "jpeg", "webp", "gif":
            return "photo"
        case "audio", "mp3", "wav", "m4a":
            return "music.note"
        default:
            return "doc.zipper"
        }
    }
}
#Preview {
    ContentView()
}
