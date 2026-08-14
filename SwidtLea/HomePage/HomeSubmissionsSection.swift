//
//  HomeSubmissionsSection.swift
//  SwiftNew
//
//  Created by QIAEN on 2026/8/14.
//

import SwiftUI

/// 投稿列表模块（对应 dsSubmission：recentSubmissions）
struct HomeSubmissionsSection: View {
    let submissions: [HomeSubmission]
    var isLoading = false
    
    var body: some View {
        HomeSectionBox(title: "投稿") {
            if isLoading {
                VStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.bgLightGray)
                            .frame(height: 56)
                            .overlay(ProgressView())
                    }
                }
            } else if submissions.isEmpty {
                Text("暂无投稿")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(submissions.enumerated()), id: \.offset) { index, submission in
                        HomeSubmissionRow(submission: submission)
                        if index < submissions.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

/// 单个投稿行
struct HomeSubmissionRow: View {
    let submission: HomeSubmission
    
    var body: some View {
        HStack(spacing: 12) {
            // 平台图标
            PlatformIcon.icon(submission.platform, size: 26)
                .frame(width: 34, height: 34)
                .background(Color(.bgLightGray))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(submission.title.isEmpty ? "未命名投稿" : submission.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                if let eventName = submission.eventName, !eventName.isEmpty {
                    Text(eventName)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer(minLength: 8)
            
            VStack(alignment: .trailing, spacing: 4) {
                HomeStatusBadge(
                    text: submission.submissionStatus.submissionDisplayName,
                    color: submission.submissionStatus.statusColor
                )
                Text(submission.submittedAt.toLocalTimeString())
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 10)
    }
}

// MARK: - 投稿状态
extension String {
    /// 投稿状态显示名
    var submissionDisplayName: String {
        switch self {
        case "PendingReview": return "待审核"
        case "Approved": return "已通过"
        case "Rejected": return "已驳回"
        case "Draft": return "草稿"
        case "Submitted": return "已提交"
        default: return self
        }
    }
    
    /// 投稿状态颜色
    var statusColor: Color {
        switch self {
        case "PendingReview", "Submitted": return .orange
        case "Approved": return .green
        case "Rejected": return .red
        default: return .secondary
        }
    }
}
