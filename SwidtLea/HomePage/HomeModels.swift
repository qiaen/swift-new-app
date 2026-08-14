//
//  HomeModels.swift
//  SwiftNew
//
//  Created by QIAEN on 2026/8/14.
//

import Foundation

// MARK: - Dashboard 总响应（对应后端 ResDashboard）
struct HomeDashboard: Decodable {
    let availableEvents: [HomeEvent]
    let recentSubmissions: [HomeSubmission]
    let mediaShortcuts: [HomeMaterial]
    // 不用展示：profile / monthlySummary / statusCard / emptyStates
}

// MARK: - 活动（对应 ResEvent，首页轮播用）
struct HomeEvent: Decodable, Identifiable {
    let id: String
    let name: String
    let bannerUrl: String
    let eventStatus: EventStatus
    let platforms: CommaSeparatedList
    let startAt: String
    let endAt: String
    let gameCode: String?
    let creatorSubmissionStatus: String?
}

// MARK: - 素材（对应 ResMaterial，首页素材模块用）
struct HomeMaterial: Decodable, Identifiable {
    let id: String
    let title: String
    let thumbnailUrl: String?
    let fileSize: Double?
    let gameCode: String?
    let type: String?
}

// MARK: - 投稿（对应 ResGetMeSubmissions 列表项）
struct HomeSubmission: Decodable, Identifiable {
    let id: String
    let title: String
    let platform: String
    let submissionStatus: String
    let submittedAt: String
    let eventName: String?
}

// MARK: - 收益（对应 ReqReward，注意后端无 id 字段，用 eventId 作为 Identifiable id）
struct HomeReward: Decodable, Identifiable {
    var id: String { eventId }
    let eventId: String
    let eventName: String
    let eventBannerUrl: String?
    let eventEndAt: String
    let approvedCount: Int
    let totalViews: Int
    let totalInteractions: Int
    let eventTotalReward: Double
    let currency: String
    let eventPaidStatus: String
    let lastPaidDate: String?

    enum CodingKeys: String, CodingKey {
        case eventId, eventName, eventBannerUrl, eventEndAt
        case approvedCount, totalViews, totalInteractions, eventTotalReward
        case currency, eventPaidStatus, lastPaidDate
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        eventId = c.lenientString(.eventId) ?? ""
        eventName = c.lenientString(.eventName) ?? ""
        eventBannerUrl = c.lenientString(.eventBannerUrl)
        eventEndAt = c.lenientString(.eventEndAt) ?? ""
        approvedCount = c.lenientInt(.approvedCount) ?? 0
        totalViews = c.lenientInt(.totalViews) ?? 0
        totalInteractions = c.lenientInt(.totalInteractions) ?? 0
        eventTotalReward = c.lenientDouble(.eventTotalReward) ?? 0
        currency = c.lenientString(.currency) ?? ""
        eventPaidStatus = c.lenientString(.eventPaidStatus) ?? ""
        lastPaidDate = c.lenientString(.lastPaidDate)
    }
}

// MARK: - 收益列表响应（list 可能为 null，容错处理）
struct RewardsData: Decodable {
    let totalPaid: Double?
    let totalPaidCurrency: String?
    let list: [HomeReward]

    enum CodingKeys: String, CodingKey {
        case totalPaid, totalPaidCurrency, list
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        totalPaid = c.lenientDouble(.totalPaid)
        totalPaidCurrency = c.lenientString(.totalPaidCurrency)
        list = (try? c.decodeIfPresent([HomeReward].self, forKey: .list)) ?? []
    }
}

// MARK: - 容错解码：兼容字段缺失 / null / 字符串数字
extension KeyedDecodingContainer {
    /// 容错取字符串：支持字符串 / 数字 / 缺失 / null
    func lenientString(_ key: Key) -> String? {
        if let v = try? decodeIfPresent(String.self, forKey: key) { return v }
        if let n = try? decodeIfPresent(Int.self, forKey: key) { return String(n) }
        if let d = try? decodeIfPresent(Double.self, forKey: key) { return String(format: "%g", d) }
        return nil
    }

    /// 容错取整数：支持整数 / 字符串数字 / 浮点 / 缺失 / null
    func lenientInt(_ key: Key) -> Int? {
        if let v = try? decodeIfPresent(Int.self, forKey: key) { return v }
        if let s = try? decodeIfPresent(String.self, forKey: key) { return Int(s) }
        if let d = try? decodeIfPresent(Double.self, forKey: key) { return Int(d) }
        return nil
    }

    /// 容错取浮点：支持浮点 / 整数 / 字符串数字 / 缺失 / null
    func lenientDouble(_ key: Key) -> Double? {
        if let v = try? decodeIfPresent(Double.self, forKey: key) { return v }
        if let s = try? decodeIfPresent(String.self, forKey: key) { return Double(s) }
        if let n = try? decodeIfPresent(Int.self, forKey: key) { return Double(n) }
        return nil
    }
}
