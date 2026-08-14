import Foundation

/// 活动素材列表请求参数
struct MaterialsRequest: APIRequestParameters {
    let eventId: String
    let pageNo: Int
    let pageSize: Int
}

/// 我的收益（已结算）请求参数
struct MyRewardsRequest: APIRequestParameters {
    let rewardStatus: String = "paid"
    let pageNo: Int
    let pageSize: Int
}
