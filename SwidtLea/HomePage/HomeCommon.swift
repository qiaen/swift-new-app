//
//  HomeCommon.swift
//  SwiftNew
//
//  Created by QIAEN on 2026/8/14.
//

import SwiftUI

// MARK: - 平台图标（直接使用 Assets 中按平台名命名的图片）
enum PlatformIcon {
    /// 已知平台名列表（对应 Assets 图片名）
    static let knownNames = ["YouTube", "TikTok", "Facebook", "Twitch", "Instagram", "X"]
    
    /// 根据平台名返回图片名，未知平台返回 nil
    static func name(for platform: String) -> String? {
        let trimmed = platform.trimmingCharacters(in: .whitespaces)
        return knownNames.contains(trimmed) ? trimmed : nil
    }
    
    /// 平台图标视图：有资源用 Image，无资源用默认 SF Symbol
    @ViewBuilder
    static func icon(_ platform: String, size: CGFloat = 16) -> some View {
        if let name = name(for: platform) {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Image(systemName: "globe")
                .font(.system(size: size * 0.9))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 模块容器
struct HomeSectionBox<Content: View>: View {
    let title: String?
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
            }
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 状态徽标
struct HomeStatusBadge: View {
    let text: String
    var color: Color = .secondary
    
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.12)))
    }
}
