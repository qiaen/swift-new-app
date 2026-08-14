//
//  HomeRewardsSection.swift
//  SwiftNew
//
//  Created by QIAEN on 2026/8/14.
//

import SwiftUI

/// 我的收益模块（对应 dsRewards：apiGetMyRewards）
struct HomeRewardsSection: View {
    let rewards: [HomeReward]
    var totalPaid: Double?
    var totalPaidCurrency: String?
    var isLoading = false
    
    var body: some View {
        HomeSectionBox(title: "我的收益") {
            if isLoading {
                VStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.bgLightGray)
                        .frame(height: 80)
                        .overlay(ProgressView())
                    ForEach(0..<2, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.bgLightGray)
                            .frame(height: 120)
                            .overlay(ProgressView())
                    }
                }
            } else if rewards.isEmpty {
                Text("暂无收益记录")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                // 总收入
                if let totalPaid {
                    HStack(spacing: 12) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(.baseGreen)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("累计已结算")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                            Text("\(totalPaid.cleanNumberString) \(totalPaidCurrency ?? "")")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.baseGreen)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(Color(.bgLightGray))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // 各活动收益
                VStack(spacing: 0) {
                    ForEach(Array(rewards.enumerated()), id: \.offset) { index, reward in
                        HomeRewardRow(reward: reward)
                        if index < rewards.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

/// 单个活动收益行
struct HomeRewardRow: View {
    let reward: HomeReward
    
    var body: some View {
        HStack(spacing: 12) {
            // 活动缩略图
            if let banner = reward.eventBannerUrl, !banner.isEmpty {
                CachedAsyncImage(urlString: banner) {
                    placeholder
                }
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                placeholder
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(reward.eventName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                // 数据统计
                HStack(spacing: 10) {
                    RewardMetric(icon: "checkmark.circle", title: "通过", value: "\(reward.approvedCount)")
                    RewardMetric(icon: "eye", title: "浏览", value: "\(reward.totalViews)")
                    RewardMetric(icon: "heart", title: "互动", value: "\(reward.totalInteractions)")
                }
                
                HStack(spacing: 6) {
                    HomeStatusBadge(
                        text: reward.eventPaidStatus == "paid" ? "已结算" : "未结算",
                        color: reward.eventPaidStatus == "paid" ? .green : .orange
                    )
                    if let lastPaid = reward.lastPaidDate, !lastPaid.isEmpty {
                        Text("\(lastPaid.toLocalTimeString().shortDateString)")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer(minLength: 4)
            
            // 收益金额
            VStack(alignment: .trailing, spacing: 4) {
                Text("+\(reward.eventTotalReward.cleanNumberString)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.baseGreen)
                Text(reward.currency)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 10)
    }
    
    private var placeholder: some View {
        ZStack {
            Color.gray.opacity(0.15)
            Image(systemName: "calendar")
                .font(.system(size: 22))
                .foregroundStyle(.secondary)
        }
    }
}

/// 收益指标小项
struct RewardMetric: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            Text("\(title) \(value)")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 数字/日期格式化
extension Double {
    /// 金额展示：整数不显示小数
    var cleanNumberString: String {
        if self == self.rounded() {
            return String(format: "%.0f", self)
        }
        return String(format: "%.2f", self)
    }
}

extension String {
    /// "yyyy-MM-dd" 截取短日期
    var shortDateString: String {
        let parts = self.split(separator: " ")
        guard let first = parts.first else { return self }
        return String(first)
    }
}
